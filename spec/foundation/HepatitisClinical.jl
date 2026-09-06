# ═══════════════════════════════════════════════════════════════════
# HepatitisClinical.jl — Clinical reference: hepatitis A & B
# Author: Mateusz Faber-Suckert
# MIT License · API-free
# ───────────────────────────────────────────────────────────────────
# Structured reference for the clinical course: symptoms BEFORE diagnosis
# (incubation → prodrome → icteric), the DIAGNOSTIC markers, and what
# follows AFTER diagnosis (staging, monitoring, surveillance).
#
# ⚠ SCOPE: descriptive reference information only. This module does NOT
#   diagnose, treat, or replace clinical assessment. Serology and staging
#   must be interpreted by a clinician in the context of the patient.
# ═══════════════════════════════════════════════════════════════════
module HepatitisClinical

export Phase, Marker, HAV_COURSE, HBV_COURSE, HAV_MARKERS, HBV_MARKERS
export interpret_hbv, MONITORING, FIBROSIS_STAGING, RED_FLAGS, course, markers

# ── clinical phase ───────────────────────────────────────────────────
struct Phase
    name::String
    timing::String
    features::Vector{String}
end

# ── laboratory marker ────────────────────────────────────────────────
struct Marker
    code::String
    meaning::String
end

# ══════════════════════════════════════════════════════════════════
# BEFORE DIAGNOSIS — clinical course
# ══════════════════════════════════════════════════════════════════

const HAV_COURSE = [
    Phase("Incubation", "15–50 days (mean ~28)",
          ["asymptomatic", "virus shed in stool — most infectious late incubation"]),
    Phase("Prodromal (pre-icteric)", "3–10 days",
          ["fever", "malaise, fatigue", "anorexia", "nausea / vomiting",
           "right-upper-quadrant discomfort", "aversion to fatty food / smoking"]),
    Phase("Icteric", "1–3 weeks",
          ["jaundice (scleral then skin)", "dark urine (choluria)",
           "pale stools (acholic)", "pruritus", "hepatomegaly, RUQ tenderness",
           "prodromal fever typically settles as jaundice appears"]),
    Phase("Convalescent", "weeks – 2 months",
          ["gradual resolution", "lifelong immunity", "NO chronic carrier state",
           "variants: relapsing or cholestatic hepatitis A"]),
]

const HBV_COURSE = [
    Phase("Incubation", "30–180 days (mean ~90)", ["asymptomatic"]),
    Phase("Prodromal (pre-icteric)", "days – weeks",
          ["fatigue, malaise, anorexia, nausea",
           "serum-sickness-like syndrome (immune-complex): arthralgia, urticaria, rash"]),
    Phase("Icteric (acute)", "1–3 weeks",
          ["jaundice, dark urine, pale stools", "RUQ pain, hepatomegaly",
           "often subclinical — many acute infections are never noticed"]),
    Phase("Chronic", "> 6 months HBsAg positive",
          ["usually asymptomatic for years", "fatigue is the commonest complaint",
           "extrahepatic: polyarteritis nodosa, membranous glomerulonephritis"]),
    Phase("Cirrhosis / decompensation", "years – decades",
          ["ascites, peripheral oedema", "spider naevi, palmar erythema",
           "gynaecomastia", "splenomegaly, caput medusae",
           "variceal bleeding (haematemesis / melaena)",
           "hepatic encephalopathy (confusion, asterixis)"]),
]

course(v::Symbol) = v === :A ? HAV_COURSE : v === :B ? HBV_COURSE :
                    error("use :A or :B")

# ══════════════════════════════════════════════════════════════════
# DIAGNOSTICS — markers
# ══════════════════════════════════════════════════════════════════

const HAV_MARKERS = [
    Marker("anti-HAV IgM", "ACUTE hepatitis A (positive at symptom onset, persists 3–6 months)"),
    Marker("anti-HAV IgG", "past infection OR vaccination → immunity (lifelong)"),
    Marker("HAV RNA (PCR)", "outbreak / research use"),
]

const HBV_MARKERS = [
    Marker("HBsAg",         "surface antigen — CURRENT infection; >6 months ⇒ chronic"),
    Marker("anti-HBs",      "immunity — recovery OR vaccination"),
    Marker("anti-HBc IgM",  "ACUTE infection (or reactivation); window-period marker"),
    Marker("anti-HBc total","past OR ongoing exposure — NOT produced by vaccination"),
    Marker("HBeAg",         "high replication / high infectivity"),
    Marker("anti-HBe",      "seroconversion — lower replication"),
    Marker("HBV DNA",       "quantitative viral load — guides treatment & monitoring"),
]

markers(v::Symbol) = v === :A ? HAV_MARKERS : v === :B ? HBV_MARKERS :
                     error("use :A or :B")

# Shared biochemistry (both A and B)
const BIOCHEMISTRY = [
    "ALT / AST — markedly raised in acute (ALT often >1000 U/L; ALT > AST)",
    "bilirubin (total & direct) — raised in icteric phase",
    "ALP / GGT — cholestatic pattern",
    "albumin & INR/PT — SYNTHETIC FUNCTION (key severity markers)",
    "platelets — low suggests portal hypertension",
]

"""
    interpret_hbv(; hbsag, anti_hbc, anti_hbs, igm_hbc=false)

Standard HBV serology interpretation (reference pattern table).
Returns a descriptive string — clinical correlation required.
"""
function interpret_hbv(; hbsag::Bool, anti_hbc::Bool, anti_hbs::Bool,
                         igm_hbc::Bool=false)
    if !hbsag && !anti_hbc && !anti_hbs
        return "Susceptible — never infected, not immune (vaccination indicated)"
    elseif !hbsag && anti_hbc && anti_hbs
        return "Immune due to natural (resolved) infection"
    elseif !hbsag && !anti_hbc && anti_hbs
        return "Immune due to VACCINATION"
    elseif hbsag && anti_hbc && igm_hbc
        return "ACUTE hepatitis B infection"
    elseif hbsag && anti_hbc && !igm_hbc
        return "CHRONIC hepatitis B infection (confirm HBsAg >6 months)"
    elseif !hbsag && anti_hbc && !anti_hbs
        return "Isolated anti-HBc — resolved infection, occult HBV, " *
               "false positive, or window period; needs further testing"
    else
        return "Uncommon/indeterminate pattern — repeat testing and clinical review"
    end
end

# ══════════════════════════════════════════════════════════════════
# AFTER DIAGNOSIS — staging, monitoring, surveillance
# ══════════════════════════════════════════════════════════════════

const FIBROSIS_STAGING = [
    "Transient elastography (FibroScan, kPa) — non-invasive stiffness",
    "APRI and FIB-4 — calculated from AST/ALT/platelets/age",
    "ELF score, PRO-C3, PIIINP, hyaluronic acid — serum fibrosis markers",
    "Liver biopsy — METAVIR F0–F4 (F4 = cirrhosis); now used selectively",
]

const MONITORING = [
    "Hepatitis A: supportive; confirm resolution — no chronic follow-up needed",
    "Hepatitis B: serial ALT + HBV DNA; HBeAg/anti-HBe status",
    "Assess treatment eligibility (nucleos(t)ide analogues) per guideline",
    "HCC surveillance: ultrasound ± AFP every 6 months if cirrhosis / high-risk HBV",
    "Severity scores: Child-Pugh, MELD",
    "Co-infection screening: HIV, HCV, and HDV (requires HBsAg positivity)",
    "Vaccinate household/sexual contacts; HBIG + vaccine for newborns & exposures",
    "Avoid alcohol; caution with hepatotoxic drugs and herbal supplements",
]

# Urgent — suggests acute liver failure; immediate hospital assessment
const RED_FLAGS = [
    "confusion, drowsiness, asterixis (hepatic encephalopathy)",
    "rising INR / coagulopathy",
    "persistent vomiting, inability to keep fluids down",
    "haematemesis or melaena (variceal bleeding)",
    "deepening jaundice with shrinking liver",
]

end # module HepatitisClinical
