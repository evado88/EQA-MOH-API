"""Reading CLSI breakpoints for the AST report.

Two small jobs: work out which CLSI organism group an identified organism falls
in, and turn a breakpoint into the zone-diameter range that belongs to a given
interpretation. Both are display helpers for the feedback report - nothing here
affects a score.
"""

GROUP_ENTEROBACTERALES = "Enterobacterales"
GROUP_PSEUDOMONAS = "Pseudomonas aeruginosa"
GROUP_ACINETOBACTER = "Acinetobacter spp."
GROUP_STAPHYLOCOCCUS = "Staphylococcus spp."
GROUP_ENTEROCOCCUS = "Enterococcus spp."
GROUP_PNEUMOCOCCUS = "Streptococcus pneumoniae"
GROUP_STREPTOCOCCUS = "Streptococcus spp."
GROUP_HAEMOPHILUS = "Haemophilus spp."
GROUP_NEISSERIA_GC = "Neisseria gonorrhoeae"
GROUP_STENOTROPHOMONAS = "Stenotrophomonas maltophilia"

# the Enterobacterales genera the scheme ships, keyed by the first word of the
# organism name. Kept explicit rather than clever: the order Enterobacterales is
# a fixed list of genera, not something to infer from the name.
_ENTEROBACTERALES_GENERA = {
    "escherichia", "klebsiella", "enterobacter", "citrobacter", "serratia",
    "proteus", "morganella", "providencia", "salmonella", "shigella",
    "yersinia", "edwardsiella", "cronobacter", "pantoea", "raoultella",
    "hafnia", "kluyvera",
}


def clsi_group_for(organism):
    """The CLSI organism group an identified organism belongs to, or None.

    None where the organism is unknown, is 'no growth', or is a group the
    breakpoint table does not cover - the report then shows no expected range,
    which is honest rather than a guessed one.
    """
    if not organism:
        return None

    name = " ".join(str(organism).split()).lower()
    if not name or name.startswith("no growth"):
        return None

    genus = name.split(" ", 1)[0].rstrip(".")

    if genus in _ENTEROBACTERALES_GENERA:
        return GROUP_ENTEROBACTERALES
    if genus == "pseudomonas" and "aeruginosa" in name:
        return GROUP_PSEUDOMONAS
    if genus == "acinetobacter":
        return GROUP_ACINETOBACTER
    if genus == "staphylococcus":
        return GROUP_STAPHYLOCOCCUS
    if genus == "enterococcus":
        return GROUP_ENTEROCOCCUS
    if genus == "streptococcus" and "pneumoniae" in name:
        return GROUP_PNEUMOCOCCUS
    if genus == "streptococcus":
        return GROUP_STREPTOCOCCUS
    if genus == "haemophilus":
        return GROUP_HAEMOPHILUS
    if genus == "neisseria" and "gonorrhoeae" in name:
        return GROUP_NEISSERIA_GC
    if genus == "stenotrophomonas":
        return GROUP_STENOTROPHOMONAS

    return None


def zone_range_for(breakpoint, interpretation):
    """The zone-diameter range (mm) a breakpoint gives for an interpretation.

    Returned as a short ASCII string the placeholder report can print ('>= 23',
    '<= 19', '20-22'); None when the breakpoint has nothing for that
    interpretation, so the caller can show a dash.
    """
    if breakpoint is None or not interpretation:
        return None

    interp = str(interpretation).strip().upper()
    s_min = breakpoint.susceptible_min
    r_max = breakpoint.resistant_max

    if interp == "S":
        return f">= {s_min}" if s_min is not None else None

    if interp == "R":
        return f"<= {r_max}" if r_max is not None else None

    if interp == "SDD":
        if breakpoint.sdd_min is not None and breakpoint.sdd_max is not None:
            return f"{breakpoint.sdd_min}-{breakpoint.sdd_max}"
        # fall through to the intermediate band if no SDD band is stated

    if interp in ("I", "SDD"):
        if s_min is not None and r_max is not None:
            low, high = r_max + 1, s_min - 1
            if low <= high:
                return f"{low}-{high}" if low != high else str(low)
        return None

    return None
