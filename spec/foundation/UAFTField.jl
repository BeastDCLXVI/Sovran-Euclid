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

using ..UFTField: CHI_FLOOR, ZHE_LIMIT, Omega, Lambda

export AntiOperator, ANTI_OPERATORS, register_anti!, anti_apply
export entropy_suction, torsion_resolve, time_nullify, double_negative
export anti_hat, anti_maat, neg_deep_floor
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

# ── ANTI-ACCENTS (negative mirror of the UFT accents) ─────────────────
# -ˆ′ Anti-Simple_hat (prime:P) — shadow unit cap: −â′ (unit into shadow).
anti_hat(v::Real) = iszero(v) ? zero(float(v)) : -v / abs(v)

# -𓆄 Anti-Feather (Ammit) — excess weight beyond truth: heart heavier
#     than the feather. > 0 ⇒ the heart is devoured (fails Ma'at).
anti_maat(v::Real) = abs(v) - ZHE_LIMIT

# -⌊⌋ Anti-Floor Deepened — shadow grounding onto the negative χ grid.
neg_deep_floor(v::Real) = -max(CHI_FLOOR, floor(abs(v) / CHI_FLOOR) * CHI_FLOOR)

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
    # ── anti-accents ──
    :neg_hat        => AntiOperator("-ˆ′", "-SIMPLE_HAT",     anti_hat,       "Shadow_Unit_Cap (prime:P)"),
    :neg_maat       => AntiOperator("-𓆄", "-MAAT_FEATHER",   anti_maat,      "Ammit_Devour_Excess"),
    :neg_deep_floor => AntiOperator("-⌊⌋", "-FLOOR_DEEPENED", neg_deep_floor, "Shadow_Grounding"),
)

register_anti!(key::Symbol, op::AntiOperator) = (ANTI_OPERATORS[key] = op)
anti_apply(key::Symbol, args...) = ANTI_OPERATORS[key].fn(args...)

end # module UAFTField
