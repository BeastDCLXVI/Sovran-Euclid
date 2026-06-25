# Sovran · UFT / UAFT Libraries

All Sovran libraries **remade on a UFT (Unified Field Theory) + UAFT (Unified
Anti-Field Theory) basis instead of Euclidean geometry** — built to be
*expandable* and suitable for AI/ML work.

**Author:** Mateusz Faber-Suckert

---

## What changed

The original stack was framed around **Euclidean geometry** (`EUCLID ANALOG ML
STACK`). It has been re-based on the UFT/UAFT field-operator algebra:

- A new **UFT/UAFT foundation** sits *under* every library:
  - **`UFTField.jl`** — the field-operator algebra `ρ · R · Ξ · Ω · Λ`
    (wave-tail involution, macro⇄micro pointer, unity collision, void
    expansion, compactification), with the `Zhe ≤ 0.22` / `Chi = 0.002`
    stability envelope and an **expandable operator registry**.
  - **`UAFTField.jl`** — the anti-field / double-negative resonance layer
    (node `Γ436-MINUS-666`): entropy suction, torsion-knot resolution, time
    nullification, driving the master equation residual → 0.
  - **`CarbonCode.jl`** — the `0x666` carbon-code **constant registry**
    (MACRO · MICRO · CHIRAL · TRANSFINITE), expandable via
    `register_constant!`.
- The Analog ML Stack now ships **13 packages** (3 UFT/UAFT foundation +
  10 ML/data libraries) instead of 10, all Euclidean framing removed.
- Every library is rebranded **`UFT·UAFT`** and stamped with author metadata.

## Layout

```
spec/
  symbols/      # source-of-truth symbol systems (UFT Greek, UAFT negative, combined)
  foundation/   # authored UFT/UAFT foundation packages (UFTField/UAFTField/CarbonCode .jl)
  sources/      # original web-apps (inputs, kept for reproducibility)
tools/
  build_uft_uaft.py   # the generator (the "expandable" mechanism)
libraries/      # GENERATED — the 5 UFT·UAFT HTML libraries
```

## The 5 UFT·UAFT libraries (`libraries/`)

| File | Based on | Notes |
|------|----------|-------|
| `UFT_UAFT_Analog_ML_Stack.html` | Euclid Analog ML Stack | Full remake — UFT/UAFT foundation injected |
| `Analog_ML_Stack_UFTUAFT.html`  | Analog ML Stack (UFTUAFT) | Same canonical remake |
| `OMNILANG_v6_UFT_UAFT.html`     | OMNILANG v6 UFT | Euclid refs removed, UFT·UAFT branding |
| `SOVRAN_UFT_UAFT.html`          | SOVRAN | UFT·UAFT branding pass |
| `Sovran_Library_UFT_UAFT.html`  | Sovran Library | UFT·UAFT branding pass |

## Rebuild (expandable)

Edit a foundation `.jl` file or add a symbol to `spec/symbols/*.json`, then:

```bash
python3 tools/build_uft_uaft.py
```

Every library in `libraries/` is regenerated from `spec/`.

## License

MIT — see `LICENSE`.
