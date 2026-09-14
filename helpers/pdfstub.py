"""A very small PDF writer, enough to stand in for the real report.

The production PT report is rendered by XtraReports from the ASP.NET service.
This exists so the report page can be built and exercised end to end before
that service is wired up: it lays out the same content, from the same
evaluation data, in a genuine PDF.

It writes Base-14 fonts only, so nothing is embedded and there is no
dependency to install.
"""

PAGE_WIDTH = 595
PAGE_HEIGHT = 842
MARGIN_LEFT = 42
MARGIN_TOP = 800
MARGIN_BOTTOM = 56

FONT_REGULAR = "F1"
FONT_BOLD = "F2"


def _escape(text):
    """PDF strings are parenthesised, so those characters need escaping"""
    if text is None:
        text = ""
    text = str(text)
    # the format is byte oriented; keep it to characters WinAnsi can hold
    text = text.encode("ascii", "replace").decode("ascii")
    return text.replace("\\", r"\\").replace("(", r"\(").replace(")", r"\)")


class PdfDocument:
    """Builds a page of text, breaking to a new page when it runs out of room."""

    def __init__(self, title="Report"):
        self.title = title
        self.pages = []
        self._ops = []
        self._y = MARGIN_TOP

    # ---------------------------------------------------------------- layout
    def _ensure_room(self, needed=16):
        if self._y - needed < MARGIN_BOTTOM:
            self.page_break()

    def page_break(self):
        if self._ops:
            self.pages.append(self._ops)
        self._ops = []
        self._y = MARGIN_TOP

    def spacer(self, height=10):
        self._y -= height

    def text(self, value, x=MARGIN_LEFT, size=9, bold=False):
        self._ensure_room(size + 4)
        self._ops.append(
            (FONT_BOLD if bold else FONT_REGULAR, size, x, self._y, value)
        )
        self._y -= size + 4

    def columns(self, cells, size=9, bold=False):
        """One row, each cell placed at its own x offset"""
        self._ensure_room(size + 4)
        for x, value in cells:
            self._ops.append(
                (FONT_BOLD if bold else FONT_REGULAR, size, x, self._y, value)
            )
        self._y -= size + 4

    def heading(self, value, size=13):
        self.spacer(6)
        self.text(value, size=size, bold=True)
        self.rule()

    def field(self, label, value, label_x=MARGIN_LEFT, value_x=230):
        self.columns([(label_x, label), (value_x, value)])

    def rule(self):
        """A rule drawn as a run of underscores, so no graphics operators"""
        self._ensure_room(8)
        self._ops.append((FONT_REGULAR, 8, MARGIN_LEFT, self._y, "_" * 108))
        self._y -= 12

    # ---------------------------------------------------------------- render
    def _content_stream(self, ops):
        parts = ["BT"]
        for font, size, x, y, value in ops:
            parts.append(f"/{font} {size} Tf")
            parts.append(f"1 0 0 1 {x} {y} Tm")
            parts.append(f"({_escape(value)}) Tj")
        parts.append("ET")
        return "\n".join(parts).encode("latin-1", "replace")

    def render(self):
        if self._ops:
            self.pages.append(self._ops)
            self._ops = []

        if not self.pages:
            self.pages = [[]]

        objects = []           # each entry is the object's bytes, 1-indexed
        page_count = len(self.pages)

        # 1 catalog, 2 pages, 3 font regular, 4 font bold,
        # then per page: a page object and a contents object
        page_ids = [5 + i * 2 for i in range(page_count)]
        content_ids = [6 + i * 2 for i in range(page_count)]

        kids = " ".join(f"{pid} 0 R" for pid in page_ids)
        objects.append(b"<< /Type /Catalog /Pages 2 0 R >>")
        objects.append(
            f"<< /Type /Pages /Kids [{kids}] /Count {page_count} >>".encode()
        )
        objects.append(
            b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica "
            b"/Encoding /WinAnsiEncoding >>"
        )
        objects.append(
            b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold "
            b"/Encoding /WinAnsiEncoding >>"
        )

        for index, ops in enumerate(self.pages):
            stream = self._content_stream(ops)
            objects.append(
                (
                    f"<< /Type /Page /Parent 2 0 R "
                    f"/MediaBox [0 0 {PAGE_WIDTH} {PAGE_HEIGHT}] "
                    f"/Resources << /Font << /{FONT_REGULAR} 3 0 R "
                    f"/{FONT_BOLD} 4 0 R >> >> "
                    f"/Contents {content_ids[index]} 0 R >>"
                ).encode()
            )
            objects.append(
                f"<< /Length {len(stream)} >>\nstream\n".encode()
                + stream
                + b"\nendstream"
            )

        out = bytearray(b"%PDF-1.4\n")
        offsets = [0]

        for number, body in enumerate(objects, start=1):
            offsets.append(len(out))
            out += f"{number} 0 obj\n".encode() + body + b"\nendobj\n"

        xref_at = len(out)
        count = len(objects) + 1

        out += f"xref\n0 {count}\n".encode()
        out += b"0000000000 65535 f \n"
        for offset in offsets[1:]:
            out += f"{offset:010d} 00000 n \n".encode()

        out += (
            f"trailer\n<< /Size {count} /Root 1 0 R >>\n"
            f"startxref\n{xref_at}\n%%EOF\n"
        ).encode()

        return bytes(out)
