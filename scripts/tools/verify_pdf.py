"""Validates a PDF's structure and prints the text it draws."""
import re, sys

data = open(r"C:\Users\nkole\AppData\Local\Temp\claude\c--Repo-Python-EQA-MOH-API\3f76dc01-bdd1-419b-923b-f24ca03ff670\scratchpad\sample_report.pdf","rb").read()
ok = True

m = re.search(rb"startxref\s+(\d+)", data)
xref_at = int(m.group(1))
print("startxref ->", xref_at)

head = data[xref_at:xref_at+20]
print("lands on  ->", head[:4])
ok &= head.startswith(b"xref")

m = re.match(rb"xref\s+0 (\d+)\s+", data[xref_at:])
count = int(m.group(1))
body = data[xref_at + m.end():]
entries = re.findall(rb"(\d{10}) (\d{5}) ([nf])", body[:count*20])
print(f"entries   -> {len(entries)} (declared {count})")
ok &= len(entries) == count

bad = []
for i, (off, gen, kind) in enumerate(entries):
    if kind == b"f":
        continue
    offset = int(off)
    expect = f"{i} 0 obj".encode()
    if not data[offset:offset+len(expect)] == expect:
        bad.append((i, offset, data[offset:offset+12]))
print("offsets   ->", "all correct" if not bad else f"WRONG: {bad}")
ok &= not bad

# the content stream length must match what the dictionary declares
for m in re.finditer(rb"<< /Length (\d+) >>\nstream\n", data):
    declared = int(m.group(1))
    start = m.end()
    end = data.index(b"\nendstream", start)
    actual = end - start
    if declared != actual:
        print(f"stream    -> length mismatch: declared {declared}, actual {actual}")
        ok = False
print("streams   -> lengths match")

pages = data.count(b"/Type /Page\n") + len(re.findall(rb"/Type /Page[ /]", data))
print("page objs ->", len(re.findall(rb"/Type /Page[ /]", data)))

# the visible text, pulled back out of the content stream
shown = re.findall(rb"\((.*?)\) Tj", data)
text = [t.decode("latin-1") for t in shown]
print("\ntext drawn (first 18 of %d):" % len(text))
for line in text[:18]:
    if line.strip("_ "):
        print("   ", line)

ok &= any("Individual Participant Performance Report" in t for t in text)
ok &= any("VL-2026-A" in t for t in text)
print("\nPASS" if ok else "\nFAIL")
sys.exit(0 if ok else 1)
