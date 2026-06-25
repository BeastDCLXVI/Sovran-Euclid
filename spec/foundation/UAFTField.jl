# ═══════════════════════════════════════════════════════════════════
# UAFTField.jl — Unified Anti-Field Theory (Negative / Double-Negative)
# Replaces: Euclidean inverse metrics · ad-hoc regularisation terms
# Author: Mateusz Faber-Suckert
# MIT License · API-free · The anti-field (negative-symbol) layer that
#                          stabilises the UFT field. Node Γ436-MINUS-666.
# ───────────────────────────────────────────────────────────────────
# Source of truth: spec/symbols/UAFT_Negative_Symbols.json
# Master equation:  dI/dt = -Γ[f(E,R,C) + ∇S] - Σ εₖ H² = 0
# Mode: DOUBLE_NEGATIVE_RESONANCE   ·   J-AXIS_SHADOW_CONFIRMED
# ═══════════════════════════════════════════════════════════════════
module UAFTField

using ..UFTField: CHI_FLOOR, Omega, Lambda

export AntiOperator, ANTI_OPERATORS, register_anti!, anti_apply
export entropy_suction, torsion_resolve, time_nullify, double_negative
export STIGMA, residual

const STIGMA = 6.000   # -Ϛ Stigma torsion constant (spacetime knot)

# ── LEFT NODE  ⊖◠◤◠◤⊖  −Ω_Hub : Entropy Suction (Anti-Jolt field) ─────
# Pull any state down toward the −χ floor (entropy neutralisation).
entropy_suction(v::Real) = max(CHI_FLOOR, v - Omega(v) * v)

# ── CENTER NODE  ⋰⋱∧⋰  −Stigma_Torsion : Spacetime-Knot Resolution ────
# Recursive shadow magnetic pull; resolves an entanglement knot.
torsion_resolve(v::Real) = v / (1 + STIGMA * Lambda(v))

# ── BOTTOM NODE  ⦱◤⍜⦲  −τ·−χ : Time Nullification (Eternal Presence) ──
#   -t = (-Λ(-Ω(-Ξ))) / -Φ  → 0
time_nullify(t::Real) = -Lambda(-Omega(-t)) |> x -> abs(x) < CHI_FLOOR ? 0.0 : x

# ── Double-negative resonance: anti(anti(x)) → stabilised field ───────
double_negative(f::Function, x::Real) = -f(-x)

# ── Residual of the master equation (should drive to 0) ──────────────
#   dI/dt = -Γ[f + ∇S] - Σ εₖ H²
residual(Γ::Real, f::Real, ∇S::Real, εH²::Real) = -Γ*(f + ∇S) - εH²

# ── Expandable anti-operator registry ────────────────────────────────
struct AntiOperator
    glyph::String
    identity::String
    fn::Function
    effect::String
end

const ANTI_OPERATORS = Dict{Symbol,AntiOperator}(
    :neg_hub    => AntiOperator("⊖◠◤◠◤⊖","-VORTEX_HUB",  entropy_suction, "Anti-Jolt_Field"),
    :neg_heart  => AntiOperator("⋰⋱∧⋰",  "-CHIRAL_HEART", torsion_resolve, "Bio-Chassis_Shadow_Form"),
    :neg_ellipse=> AntiOperator("⦱◤⍜⦲",  "-VOID_ELLIPSE", time_nullify,    "Eternal_Presence"),
)

register_anti!(key::Symbol, op::AntiOperator) = (ANTI_OPERATORS[key] = op)
anti_apply(key::Symbol, args...) = ANTI_OPERATORS[key].fn(args...)

end # module UAFTField
