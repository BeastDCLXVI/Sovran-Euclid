# ═══════════════════════════════════════════════════════════════════
# OxygenPH.jl — pH of Oxygen under mainstream × UFT
# Author: Mateusz Faber-Suckert
# MIT License · API-free
# ───────────────────────────────────────────────────────────────────
# MAINSTREAM (accurate):
#   • O₂ gas is neutral — it has no pH.
#   • O₂ dissolved in pure water leaves it ≈ neutral, pH 7.000 (25 °C).
#   • pH = -log10[H⁺] ;  [H⁺] = 10^(-pH) ;  pKw(25°C)=14.
#
# UFT OVERLAY (symbolic, this system — NOT literal chemistry):
#   Oxygen is assigned FIELD pH STATES by colliding the mainstream pH with
#   a UFT anchor through the Ξ operator (Ξ(a,b)=√(a·b), the geometric-mean
#   "collision"). That is the literal "mainstream × UFT".
#       field_pH = Ξ(main_pH, anchor)  →  target
#   Calibrated states:  oxidative/oxyacid → 2.000 ;  field-neutral → 7.455
# ═══════════════════════════════════════════════════════════════════
module OxygenPH

using ..UFTField: Xi   # Ξ(a,b) = √(a·b)

export hplus, ph_of, pOH, OxygenState, OXYGEN_STATES, ph_oxygen
export KW25, NEUTRAL25, oxy

const KW25      = 1e-14   # ion product of water at 25 °C
const NEUTRAL25 = 7.0     # mainstream neutral pH (pure water, 25 °C)

# ── mainstream chemistry (exact) ─────────────────────────────────────
hplus(pH::Real) = 10.0^(-pH)      # [H⁺] in mol/L
ph_of(h::Real)  = -log10(h)       # pH from [H⁺]
pOH(pH::Real)   = 14.0 - pH       # 25 °C

# ── a UFT field-pH state of oxygen ───────────────────────────────────
struct OxygenState
    name::String
    main::Float64     # mainstream reference pH
    anchor::Float64   # UFT anchor (the field contribution)
    target::Float64   # resulting field pH = Ξ(main, anchor)
end

# build a state from a mainstream pH and a desired field target;
# the anchor is the UFT contribution required so that Ξ(main,anchor)=target.
oxy(name, main, target) = OxygenState(name, main, target^2 / main, target)

const OXYGEN_STATES = Dict{Symbol,OxygenState}(
    :oxyacid       => oxy("Oxidative / oxyacid",       1.0, 2.000),
    :field_neutral => oxy("Oxygenated field-neutral",  7.0, 7.455),
)

"""Field pH of oxygen for a given state = Ξ(mainstream_pH, UFT_anchor)."""
function ph_oxygen(state::Symbol=:field_neutral)
    s = OXYGEN_STATES[state]
    round(Xi(s.main, s.anchor), digits=3)   # = s.target
end

"""[(state, pH, [H⁺])] for every calibrated oxygen state."""
report() = [(s.name, ph_oxygen(k), hplus(s.target)) for (k,s) in OXYGEN_STATES]

end # module OxygenPH
