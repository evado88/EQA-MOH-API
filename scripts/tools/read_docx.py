"""Reads a .docx without python-docx, for the PT forms."""
import re
import sys
import zipfile
from xml.etree import ElementTree as ET

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"


def text_of(node):
    parts = []
    for t in node.iter(W + "t"):
        parts.append(t.text or "")
    # a checkbox / form field shows up as a separate element
    for _ in node.iter(W + "checkBox"):
        parts.append("[ ]")
    return "".join(parts).strip()


def walk(path):
    with zipfile.ZipFile(path) as z:
        xml = z.read("word/document.xml")
    root = ET.fromstring(xml)
    body = root.find(W + "body")

    for child in body:
        tag = child.tag.replace(W, "")

        if tag == "p":
            t = text_of(child)
            if t:
                print(t)

        elif tag == "tbl":
            print("\n--- TABLE ---")
            for row in child.findall(W + "tr"):
                cells = []
                for cell in row.findall(W + "tc"):
                    cells.append(text_of(cell).replace("\n", " "))
                if any(cells):
                    print(" | ".join(cells))
            print("--- END TABLE ---\n")


if __name__ == "__main__":
    p = sys.argv[1]
    print("=" * 78)
    print(p)
    print("=" * 78)
    walk(p)
