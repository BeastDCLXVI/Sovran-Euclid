# ═══════════════════════════════════════════════════════════════════
# qubit_agi_demo.jl — drive the Sovran code-qubit + arm a 6 GB AGI fleet
# Author: Mateusz Faber-Suckert
#
#   julia demo/qubit_agi_demo.jl
# ═══════════════════════════════════════════════════════════════════
include(joinpath(@__DIR__, "..", "spec", "foundation", "Sovran.jl"))
using .Sovran
using .Sovran.SovranQubit
using .Sovran.AnalogAGI

println("── 1. A single Sovran code-qubit ──────────────────────────")
q = squbit(1)
hadamard!(q, 0)
println("  H|0⟩ Bloch vector = ", round.(bloch(q), digits=3))
println("  P(measure) = ", round.(probabilities(q), digits=3))

println("\n── 2. Bell pair via Ξ unity-collision ─────────────────────")
b = squbit(2)
xi_entangle!(b, 0, 1)
println("  counts over 4000 shots = ", sample(b, 4000))

println("\n── 3. Below-threshold LOGICAL qubit (Willow + UAFT) ───────")
for d in (3, 5, 7)
    lq = LogicalQubit(d; p_phys=0.001, p_th=0.01, topological=true)
    println("  d=$d  below_threshold=$(below_threshold(lq))  ",
            "logical_error=", logical_error(lq))
end

println("\n── 4. Arm an Analog Super-AGI fleet inside 6 GB ───────────")
fleet = arm_fleet(budget_gb=6.0)
println(summary(fleet))
println("\n  mean cognition after one fleet step = ",
        round(fleet_step!(fleet), digits=4))
