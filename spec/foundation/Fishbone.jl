# ═══════════════════════════════════════════════════════════════════
# Fishbone.jl — Fish pin-bone compound registry (materials chemistry)
# Author: Mateusz Faber-Suckert
# MIT License · API-free · Expandable registry of the compounds that make
#               up fish intermuscular ("pin") bone.
# ───────────────────────────────────────────────────────────────────
# SCOPE: composition and materials chemistry only. This module makes NO
#        medical, therapeutic or nutritional-claim assertions.
#
# Bulk composition (dry weight, typical ranges):
#   mineral ~60-70 %   ·   organic ~20-30 %   ·   lipid ~1-5 %
# Dominant phases: carbonated hydroxyapatite + type I collagen.
# ═══════════════════════════════════════════════════════════════════
module Fishbone

export Compound, COMPOUNDS, register_compound!, molar_mass, phase
export PHASE_FRACTIONS, CA_P_STOICH, CA_P_RANGE, TRACE_SUBSTITUENTS
export ca_p_ratio, calcine, by_phase, report
export COLLAGEN_DENAT_C

# ── atomic weights (IUPAC, g/mol) ────────────────────────────────────
const AW = Dict(
    "H"=>1.008, "C"=>12.011, "N"=>14.007, "O"=>15.999,
    "F"=>18.998403, "Mg"=>24.305, "P"=>30.973762, "Ca"=>40.078,
)

"""Molar mass from an element=>count composition map."""
molar_mass(comp::Dict{String,<:Real}) = sum(AW[e] * n for (e, n) in comp)

# ── a bone compound ──────────────────────────────────────────────────
struct Compound
    name::String
    formula::String
    comp::Dict{String,Float64}   # element => stoichiometric count
    phase::Symbol                # :mineral :organic :lipid
    note::String
end

phase(c::Compound) = c.phase
molar_mass(c::Compound) = molar_mass(c.comp)

# ── registry ─────────────────────────────────────────────────────────
const COMPOUNDS = Dict{Symbol,Compound}(

  # ── MINERAL PHASE ────────────────────────────────────────────────
  :hydroxyapatite => Compound(
      "Hydroxyapatite (stoichiometric)", "Ca10(PO4)6(OH)2",
      Dict("Ca"=>10.0, "P"=>6.0, "O"=>26.0, "H"=>2.0), :mineral,
      "Dominant mineral. In bone it is Ca-deficient and CO3-substituted."),

  :fluorapatite => Compound(
      "Fluorapatite", "Ca10(PO4)6F2",
      Dict("Ca"=>10.0, "P"=>6.0, "O"=>24.0, "F"=>2.0), :mineral,
      "F- substituting OH- in the apatite lattice."),

  :beta_tcp => Compound(
      "β-Tricalcium phosphate", "Ca3(PO4)2",
      Dict("Ca"=>3.0, "P"=>2.0, "O"=>8.0), :mineral,
      "Chiefly a calcination product of Ca-deficient apatite."),

  :whitlockite => Compound(
      "Whitlockite (Mg-substituted)", "(Ca2.5Mg0.5)(PO4)2",
      Dict("Ca"=>2.5, "Mg"=>0.5, "P"=>2.0, "O"=>8.0), :mineral,
      "Minor phase; nominal Mg occupancy shown."),

  # ── ORGANIC PHASE ────────────────────────────────────────────────
  :hydroxyproline => Compound(
      "4-Hydroxyproline", "C5H9NO3",
      Dict("C"=>5.0, "H"=>9.0, "N"=>1.0, "O"=>3.0), :organic,
      "Collagen marker residue; lower in fish than mammalian collagen."),

  # ── LIPID FRACTION ───────────────────────────────────────────────
  :epa => Compound(
      "Eicosapentaenoic acid (EPA, 20:5 n-3)", "C20H30O2",
      Dict("C"=>20.0, "H"=>30.0, "O"=>2.0), :lipid,
      "From marrow / adhering tissue."),

  :dha => Compound(
      "Docosahexaenoic acid (DHA, 22:6 n-3)", "C22H32O2",
      Dict("C"=>22.0, "H"=>32.0, "O"=>2.0), :lipid,
      "From marrow / adhering tissue."),
)

"""Register / override a compound — the registry is open & expandable."""
register_compound!(key::Symbol, c::Compound) = (COMPOUNDS[key] = c)

by_phase(p::Symbol) = filter(kv -> kv.second.phase === p, COMPOUNDS)

# ── macromolecules (no single stoichiometric formula) ────────────────
const MACROMOLECULES = Dict{Symbol,NamedTuple}(
    :collagen_I  => (name="Type I collagen (tropocollagen)", mass_Da=300_000,
                     note="~90% of the organic matrix; (Gly-X-Y)n triple helix."),
    :gelatin     => (name="Gelatin", mass_Da=0,
                     note="Thermally denatured collagen; variable mass."),
    :osteocalcin => (name="Osteocalcin", mass_Da=5_800,
                     note="γ-carboxyglutamate-containing non-collagenous protein."),
    :decorin     => (name="Decorin (proteoglycan)", mass_Da=40_000,
                     note="Carries chondroitin/dermatan sulfate GAG chains."),
)

# fish (cold-water) collagen denaturation temperature, °C
const COLLAGEN_DENAT_C = (25.0, 30.0)

# ── bulk composition ─────────────────────────────────────────────────
const PHASE_FRACTIONS = Dict(          # fraction of dry weight
    :mineral => (0.60, 0.70),
    :organic => (0.20, 0.30),
    :lipid   => (0.01, 0.05),
)

const CA_P_STOICH = 10 / 6             # 1.667 — stoichiometric apatite
const CA_P_RANGE  = (1.50, 1.67)       # fish bone: Ca-deficient apatite

"""Ca/P molar ratio of a compound (NaN if it has no Ca or P)."""
function ca_p_ratio(c::Compound)
    ca = get(c.comp, "Ca", 0.0); p = get(c.comp, "P", 0.0)
    p == 0 ? NaN : ca / p
end

const TRACE_SUBSTITUENTS = ["Mg2+", "Na+", "K+", "Sr2+", "Zn2+", "F-", "Cl-", "CO3 2-"]

# ── thermal processing ───────────────────────────────────────────────
"""Phases present after calcining fish bone at `T` °C."""
function calcine(T::Real)
    T < 200  && return (stage="native",      phases=[:hydroxyapatite, :collagen_I])
    T < 600  && return (stage="pyrolysis",   phases=[:hydroxyapatite])
    T <= 900 && return (stage="calcined",    phases=[:hydroxyapatite, :beta_tcp])
    return         (stage="over-fired", phases=[:hydroxyapatite, :beta_tcp])
end

function report()
    [(c.name, c.formula, round(molar_mass(c), digits=2), c.phase)
     for c in values(COMPOUNDS)]
end

end # module Fishbone
