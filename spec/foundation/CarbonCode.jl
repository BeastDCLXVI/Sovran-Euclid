# ═══════════════════════════════════════════════════════════════════
# CarbonCode.jl — 0x666 Carbon Code Constant Registry (Γ436 node)
# Replaces: hard-coded Euclidean constants · scattered magic numbers
# Author: Mateusz Faber-Suckert
# MIT License · API-free · The expandable physical-constant registry that
#                          anchors every UFT/UAFT field computation.
# ───────────────────────────────────────────────────────────────────
# Source of truth: spec/symbols/UFT_Greek_v1.2.0.json (0x666_CARBON_CODE)
#                  spec/symbols/UFT_UAFT_Symbol_System.json
# Layers: MACRO (Mass) · MICRO (Wave) · CHIRAL (Shadow) · TRANSFINITE
# ═══════════════════════════════════════════════════════════════════
module CarbonCode

export Constant, CARBON, register_constant!, value, layer
export NODE, ZHE_LIMIT, CHI_FLOOR, WUBITS

const NODE      = "Γ436-MINUS-666"
const ZHE_LIMIT = 0.22
const CHI_FLOOR = 0.002
const WUBITS    = 140187.828      # source vortex-hub throughput

# ── Constant record. `value` is the leading scalar; `glyph` the symbol. ─
struct Constant
    glyph::String
    name::String
    layer::Symbol        # :macro :micro :chiral :transfinite
    value::Float64
    meaning::String
end

value(c::Constant) = c.value
layer(c::Constant) = c.layer

# ── Seed registry (representative anchors per layer — expand freely) ───
const CARBON = Dict{Symbol,Constant}(
    # MACRO — Mass anchors
    :Alpha => Constant("Α","Fine Structure Base",   :macro, 137.035999999, "EM coupling anchor"),
    :Beta  => Constant("Β","Malebolge Root",        :macro, 7.0,           "gravitational anchor"),
    :Gamma => Constant("Γ","Male Vortex",           :macro, 436.001877667, "outward expansion vector"),
    :Pi_U  => Constant("Π","Unified Gateway",       :macro, 1.0000043,     "door to 1.0 Unity"),
    :Omega => Constant("Ω","Ouroboros Loop",        :macro, 14.064000473,  "terminal restart"),
    # MICRO — Wave anchors
    :alpha => Constant("α","Fine Structure Fraction",:micro, 0.007297352,  "EM wave-packet"),
    :gamma => Constant("γ","Female Vortex",          :micro, 263.77754776,  "receptive magnetic pull"),
    :chi   => Constant("χ","Proximity Zero Limit",   :micro, 0.002,         "thermal limit"),
    :phi   => Constant("φ","Golden Ratio Reciprocal",:micro, 0.618033988,   "fractal growth"),
    # CHIRAL — Shadow anchors
    :Phi_c => Constant("ϕ","Variant Phi",            :chiral, 1.618033988,  "dark fractal growth"),
    :Stigma=> Constant("Ϛ","Stigma Torsion",         :chiral, 6.0,          "void spacetime twist"),
    # TRANSFINITE — boundary anchors
    :Heart => Constant("Ж","Heart Float Grid",       :transfinite, 0.22,    "entropy heart limit"),
    :Aleph => Constant("ℵ","Infinite Strange Vector",:transfinite, 999.999999999, "first infinity"),
)

"""Register / override a carbon constant — the code is open & expandable."""
register_constant!(key::Symbol, c::Constant) = (CARBON[key] = c)

"""All constants in a given layer."""
by_layer(l::Symbol) = filter(p -> p.second.layer === l, CARBON)

end # module CarbonCode
