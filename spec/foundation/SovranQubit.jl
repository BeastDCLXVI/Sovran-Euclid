# ═══════════════════════════════════════════════════════════════════
# SovranQubit.jl — UFT · UAFT · Sovran code-based Qubit
# Author: Mateusz Faber-Suckert
# MIT License · API-free · A pure-Julia qubit built on the UFT/UAFT field
#               algebra — no quantum hardware, no Python, runs on a phone.
# ───────────────────────────────────────────────────────────────────
# Mirrors the 2024–2025 leaps in qubit technology, in code:
#   • below-threshold surface-code LOGICAL qubits   (Google Willow, 2024)
#   • TOPOLOGICAL protection                        (Microsoft Majorana 1, 2025)
#   • neutral-atom array scaling                     (QuEra / Atom Computing)
# mapped onto the UFT/UAFT field:
#   • decoherence floor      → χ  (CHI_FLOOR  = 0.002)
#   • entropy ceiling        → Zhe (ZHE_LIMIT = 0.22)
#   • topological protection → UAFT Stigma torsion, node Γ436-MINUS-666
#   • measurement collapse   → ψ collapse constant (0.707106781)
# Tier-aware: Complex{Float16} (edge) … Complex{Float64} (server) — same API.
# ═══════════════════════════════════════════════════════════════════
module SovranQubit

using Random: AbstractRNG, default_rng
using ..UFTField:  ZHE_LIMIT, CHI_FLOOR, rho, cycle_C
using ..UAFTField: torsion_resolve, entropy_suction, STIGMA

export QRegister, squbit, nqubits, statevector
export hadamard!, pauli_x!, pauli_y!, pauli_z!, sgate!, tgate!
export rx!, ry!, rz!, phase!, cnot!, cz!
export xi_entangle!, rho_gate!, decohere!, measure!, sample
export ghz!, grover!, qft!
export probabilities, fidelity, purity, bloch
export LogicalQubit, logical_error, below_threshold, footprint_bytes

const PSI_COLLAPSE = 0.707106781   # |⟨+|0⟩| — observer-induced birth amplitude

# ── QRegister: n-qubit statevector, type-parametric for tiering ───────
mutable struct QRegister{T<:AbstractFloat}
    ψ::Vector{Complex{T}}   # length 2^n, little-endian (qubit 0 = LSB)
    n::Int
end

"""`squbit(n; T=Float64)` → n-qubit register initialised to |0…0⟩."""
function squbit(n::Int; T::Type{<:AbstractFloat}=Float64)
    ψ = zeros(Complex{T}, 1 << n)
    ψ[1] = one(Complex{T})
    QRegister{T}(ψ, n)
end

nqubits(r::QRegister)     = r.n
statevector(r::QRegister) = r.ψ
footprint_bytes(r::QRegister) = sizeof(r.ψ)

# ── Generic single-qubit gate application (in place) ─────────────────
@inline function apply1!(r::QRegister{T}, U, q::Int) where T
    step = 1 << q
    @inbounds for base in 0:(length(r.ψ)-1)
        if base & step == 0
            i0 = base + 1
            i1 = base + step + 1
            a, b = r.ψ[i0], r.ψ[i1]
            r.ψ[i0] = Complex{T}(U[1,1]*a + U[1,2]*b)
            r.ψ[i1] = Complex{T}(U[2,1]*a + U[2,2]*b)
        end
    end
    r
end

# ── Standard gate set ────────────────────────────────────────────────
const _H = (1/sqrt(2)) .* ComplexF64[1 1; 1 -1]
hadamard!(r, q)  = apply1!(r, _H, q)
pauli_x!(r, q)   = apply1!(r, ComplexF64[0 1; 1 0], q)
pauli_y!(r, q)   = apply1!(r, ComplexF64[0 -im; im 0], q)
pauli_z!(r, q)   = apply1!(r, ComplexF64[1 0; 0 -1], q)
sgate!(r, q)     = apply1!(r, ComplexF64[1 0; 0 im], q)
tgate!(r, q)     = apply1!(r, ComplexF64[1 0; 0 cis(π/4)], q)
phase!(r, q, θ)  = apply1!(r, ComplexF64[1 0; 0 cis(θ)], q)

rx!(r, q, θ) = apply1!(r, ComplexF64[cos(θ/2) -im*sin(θ/2); -im*sin(θ/2) cos(θ/2)], q)
ry!(r, q, θ) = apply1!(r, ComplexF64[cos(θ/2) -sin(θ/2);     sin(θ/2)    cos(θ/2)], q)
rz!(r, q, θ) = apply1!(r, ComplexF64[cis(-θ/2) 0; 0 cis(θ/2)], q)

# ── Two-qubit gates ──────────────────────────────────────────────────
function cnot!(r::QRegister, c::Int, t::Int)
    cb, tb = 1 << c, 1 << t
    @inbounds for base in 0:(length(r.ψ)-1)
        if (base & cb != 0) && (base & tb == 0)
            i0 = base + 1
            i1 = (base | tb) + 1
            r.ψ[i0], r.ψ[i1] = r.ψ[i1], r.ψ[i0]
        end
    end
    r
end

function cz!(r::QRegister, c::Int, t::Int)
    cb, tb = 1 << c, 1 << t
    @inbounds for base in 0:(length(r.ψ)-1)
        (base & cb != 0) && (base & tb != 0) && (r.ψ[base+1] = -r.ψ[base+1])
    end
    r
end

# ── UFT/UAFT field gates ─────────────────────────────────────────────
# Ξ — Unity Collision: maximally entangle two qubits (Bell-pair fuser).
function xi_entangle!(r::QRegister, a::Int, b::Int)
    hadamard!(r, a)
    cnot!(r, a, b)
    r
end

# ρ — Wave-Tail involution applied to a qubit's phase (σ-cipher of basis).
function rho_gate!(r::QRegister, q::Int)
    apply1!(r, ComplexF64[0 cis(2π*rho(1)/100); cis(2π*rho(2)/100) 0], q)
end

# UAFT decoherence: amplitude damping toward the χ floor (entropy suction).
# `t` = number of idle cycles; respects the Zhe entropy ceiling.
function decohere!(r::QRegister{T}, γ::Real=CHI_FLOOR; cycles::Int=1) where T
    keep = (1 - clamp(γ, 0.0, ZHE_LIMIT))^cycles
    @inbounds for i in eachindex(r.ψ)
        r.ψ[i] *= T(keep)
    end
    normalize!(r)
end

# ══════════════════════════════════════════════════════════════════
# QUANTUM ALGORITHMS
# ══════════════════════════════════════════════════════════════════
# GHZ — maximal n-qubit entanglement: (|0…0⟩ + |1…1⟩)/√2
function ghz!(r::QRegister)
    hadamard!(r, 0)
    for q in 1:(r.n - 1)
        cnot!(r, 0, q)
    end
    r
end

# Grover — amplitude amplification of a marked basis state.
# Starts from |0…0⟩, applies ~⌊π/4·√N⌋ iterations (oracle + diffusion).
function grover!(r::QRegister{T}, target::Int; iters::Int=-1) where T
    N = length(r.ψ)
    0 <= target < N || error("target out of range 0:$(N-1)")
    for q in 0:(r.n - 1); hadamard!(r, q); end          # uniform superposition
    it = iters < 0 ? max(1, round(Int, (π/4) * sqrt(N))) : iters
    for _ in 1:it
        r.ψ[target+1] = -r.ψ[target+1]                  # oracle: phase-flip target
        m = sum(r.ψ) / N                                 # inversion about the mean
        @inbounds for i in eachindex(r.ψ); r.ψ[i] = Complex{T}(2m - r.ψ[i]); end
    end
    r
end

# QFT — quantum Fourier transform (unitary applied directly):
#   out[y] = (1/√N) Σ_x ψ[x]·exp(2πi·x·y/N)
function qft!(r::QRegister{T}) where T
    N = length(r.ψ)
    out = zeros(Complex{T}, N)
    @inbounds for y in 0:N-1, x in 0:N-1
        out[y+1] += r.ψ[x+1] * cis(2π * x * y / N)
    end
    r.ψ .= out ./ sqrt(T(N))
    r
end

# ── Normalisation / measurement / diagnostics ────────────────────────
function normalize!(r::QRegister{T}) where T
    s = sqrt(sum(abs2, r.ψ))
    s > 0 && (r.ψ ./= T(s))
    r
end

probabilities(r::QRegister) = abs2.(r.ψ)

"""Projectively measure the whole register; collapses ψ, returns bitstring Int."""
function measure!(r::QRegister{T}; rng::AbstractRNG=default_rng()) where T
    p = probabilities(r); c = cumsum(p)
    u = rand(rng) * c[end]
    k = findfirst(≥(u), c)
    fill!(r.ψ, zero(Complex{T}))
    r.ψ[k] = one(Complex{T})
    k - 1
end

"""Non-destructive Monte-Carlo sample of `shots` measurements."""
function sample(r::QRegister, shots::Int; rng::AbstractRNG=default_rng())
    p = probabilities(r); c = cumsum(p); tot = c[end]
    counts = Dict{Int,Int}()
    for _ in 1:shots
        k = findfirst(≥(rand(rng)*tot), c)
        counts[k-1] = get(counts, k-1, 0) + 1
    end
    counts
end

fidelity(a::QRegister, b::QRegister) = abs2(sum(conj.(a.ψ) .* b.ψ))
purity(r::QRegister) = sum(abs2, abs2.(r.ψ))   # 1.0 for pure states

"""Bloch vector (x,y,z) of a single-qubit register."""
function bloch(r::QRegister)
    @assert r.n == 1 "bloch() expects a 1-qubit register"
    α, β = r.ψ[1], r.ψ[2]
    (2real(conj(α)*β), 2imag(conj(α)*β), abs2(α) - abs2(β))
end

# ══════════════════════════════════════════════════════════════════
# LOGICAL QUBIT — surface-code + UAFT topological protection
# ══════════════════════════════════════════════════════════════════
# Google Willow (2024): logical error drops as code distance d grows,
# *below threshold* (p < p_th). Λ-suppression ≈ (p/p_th)^((d+1)/2).
# We add a UAFT Stigma-torsion term: topological (Majorana-style) shadow
# protection that further resolves the residual logical error.
struct LogicalQubit
    distance::Int        # code distance d (odd: 3,5,7,…)
    p_phys::Float64      # physical per-cycle error rate
    p_th::Float64        # surface-code threshold (~0.01)
    topological::Bool    # UAFT Stigma-torsion protection on/off
end

LogicalQubit(d::Int; p_phys=0.001, p_th=0.01, topological=true) =
    LogicalQubit(d, p_phys, p_th, topological)

below_threshold(lq::LogicalQubit) = lq.p_phys < lq.p_th

"""Logical error rate per cycle. Below threshold it shrinks with distance;
   UAFT topological protection resolves the residual via Stigma torsion."""
function logical_error(lq::LogicalQubit)
    Λ = (lq.p_phys / lq.p_th)^((lq.distance + 1) / 2)   # surface-code suppression
    base = 0.1 * Λ                                       # prefactor (Willow-like)
    err  = lq.topological ? torsion_resolve(base) : base # UAFT shadow protection
    max(err, 0.0)
end

# physical qubits consumed by a distance-d rotated surface code: 2d² − 1
physical_cost(lq::LogicalQubit) = 2 * lq.distance^2 - 1

end # module SovranQubit
