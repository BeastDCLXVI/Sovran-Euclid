#!/usr/bin/env python3
"""Reference port of SovranQubit.jl / AnalogAGI.jl — validates the math the
Julia code computes (no Julia runtime needed). Mirrors the same formulas."""
import math, cmath, random

CHI_FLOOR, ZHE_LIMIT, STIGMA, GB = 0.002, 0.22, 6.000, 1024**3

# ── UFT/UAFT ops (mirror UFTField.jl / UAFTField.jl) ──────────────────
def Lambda(v): return 1/(abs(v)+1)
def Omega(v):  return 1/(1-min(v, 1-CHI_FLOOR))
def torsion_resolve(v): return v/(1+STIGMA*Lambda(v))
def cycle_C(c, cp):
    R = lambda v: CHI_FLOOR if v == 0 else 1/v
    out = Lambda(Omega(math.sqrt(abs(R(c)*R(cp)))))
    return out if out > ZHE_LIMIT else max(out, CHI_FLOOR)

# ── 1. Single qubit: H|0> ─────────────────────────────────────────────
H = [[1/math.sqrt(2), 1/math.sqrt(2)], [1/math.sqrt(2), -1/math.sqrt(2)]]
a, b = 1+0j, 0+0j
a, b = H[0][0]*a + H[0][1]*b, H[1][0]*a + H[1][1]*b
bloch = (2*(a.conjugate()*b).real, 2*(a.conjugate()*b).imag, abs(a)**2-abs(b)**2)
print("1. H|0>  Bloch =", tuple(round(x,3) for x in bloch),
      " P =", [round(abs(a)**2,3), round(abs(b)**2,3)])
assert abs(abs(a)**2 - 0.5) < 1e-9 and abs(bloch[0]-1.0) < 1e-9, "H|0> wrong"

# ── 2. Bell pair: H on q0 then CNOT(0->1) ─────────────────────────────
psi = [1+0j, 0, 0, 0]                       # |00>, little-endian
# H on qubit 0
new = psi[:]
for base in range(4):
    if base & 1 == 0:
        i0, i1 = base, base | 1
        x, y = psi[i0], psi[i1]
        new[i0], new[i1] = H[0][0]*x+H[0][1]*y, H[1][0]*x+H[1][1]*y
psi = new
# CNOT control 0 target 1
for base in range(4):
    if (base & 1) and not (base & 2):
        psi[base], psi[base|2] = psi[base|2], psi[base]
probs = [round(abs(z)**2,3) for z in psi]
print("2. Bell  P(|00>,|01>,|10>,|11>) =", probs)
assert abs(probs[0]-0.5)<1e-9 and abs(probs[3]-0.5)<1e-9 and probs[1]==0 and probs[2]==0

# ── 3. Logical qubit: below-threshold suppression + UAFT protection ───
print("3. Logical qubit (p_phys=0.001, p_th=0.01):")
prev = 1.0
for d in (3,5,7):
    Lam = (0.001/0.01)**((d+1)/2)
    err = torsion_resolve(0.1*Lam)
    print(f"     d={d}  below_threshold={0.001<0.01}  logical_error={err:.3e}")
    assert err < prev, "error must shrink with distance"
    prev = err

# ── 4. Fleet capacity within 6 GB (mirror agent_footprint) ────────────
def agent_footprint(params, wbytes, n_qubits, qbytes, scratch=512_000):
    return params*wbytes + (1<<n_qubits)*qbytes + scratch + 512

def fleet_capacity(budget_gb, fp):
    return int(budget_gb*GB // fp)

params, wbytes, nq, qbytes = 1_500_000, 1, 8, 4   # INT8 weights, Float16 complex
fp = agent_footprint(params, wbytes, nq, qbytes)
cap = fleet_capacity(6.0, fp)
print("4. 6 GB fleet:")
print(f"     per-agent footprint = {fp/1024**2:.3f} MB")
print(f"     agents armed        = {cap}")
print(f"     fleet uses          = {cap*fp/GB:.3f} GB / 6 GB")
print(f"     total code-qubits   = {cap*nq}")
assert cap > 1000, "should arm many (>1000) agents in 6 GB"
assert cap*fp <= 6*GB, "must stay within budget"

print("\nALL CHECKS PASSED ✓")
