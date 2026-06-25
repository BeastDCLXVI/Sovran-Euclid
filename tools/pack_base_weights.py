#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════════
# pack_base_weights.py — pack INT8 base weights into a runnable HTML
# Author: Mateusz Faber-Suckert
#
# Hand-crafts small, interpretable base weights for filtering TEXT and
# IMAGES, quantises them to INT8, base64-packs them, and injects them
# into tools/intro_template.html → libraries/Sovran_Qubit_AGI_Intro.html
#
# Expandable: edit the weight tables below and re-run.
#   python3 tools/pack_base_weights.py
# ═══════════════════════════════════════════════════════════════════
import base64, json, struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TPL  = ROOT / "tools" / "intro_template.html"
OUT  = ROOT / "libraries" / "Sovran_Qubit_AGI_Intro.html"

# ── INT8 symmetric quantisation ───────────────────────────────────────
def quantise(weights):
    flat = [float(w) for w in weights]
    scale = (max(abs(w) for w in flat) or 1.0) / 127.0
    q = bytes((max(-127, min(127, round(w / scale))) & 0xFF) for w in flat)
    return base64.b64encode(q).decode("ascii"), scale

# ── TEXT base weights — lexicon linear filter (+ = push toward FILTER) ─
TEXT_LEXICON = {
    # spam / scam / promo
    "free":2.2,"winner":2.4,"win":1.6,"prize":2.3,"cash":2.0,"click":1.9,"offer":1.8,
    "limited":1.6,"urgent":2.1,"now":1.0,"buy":1.5,"cheap":1.7,"discount":1.6,"deal":1.4,
    "guarantee":1.8,"guaranteed":1.8,"credit":1.5,"loan":1.7,"investment":1.4,"bonus":1.6,
    "subscribe":1.3,"congratulations":2.0,"selected":1.5,"exclusive":1.4,"risk":1.2,
    # toxic / abusive (kept mild)
    "hate":2.0,"stupid":1.8,"idiot":1.9,"dumb":1.6,"ugly":1.5,"trash":1.6,"worst":1.4,
    "loser":1.7,"shut":1.3,"garbage":1.5,
    # clean / benign (negative → push toward ALLOW)
    "thanks":-1.6,"please":-1.2,"meeting":-1.4,"report":-1.3,"project":-1.3,"team":-1.2,
    "hello":-1.1,"question":-1.0,"help":-0.9,"today":-0.8,"data":-1.1,"research":-1.2,
    "attached":-1.0,"regards":-1.3,"schedule":-1.0,"update":-0.7,"review":-0.8,"document":-1.0,
}
TEXT_BIAS = -0.6     # default: ALLOW

# ── IMAGE base weights — quality classifier ───────────────────────────
# feature order (must match intro_template.html imageFeatures()):
IMG_FEATURES = ["meanLum","contrast","edgeEnergy","saturation","colorful",
                "darkFrac","brightFrac","rMean","gMean","bMean"]
IMG_CLASSES  = ["PASS","TOO DARK","TOO BLURRY","OVER-EXPOSED","OVER-SATURATED"]
#               meanL contr edge  sat  colf dark brt  r    g    b
IMG_W = [
    [ 0.3, 1.2, 1.6,-0.3,-0.4,-2.6,-2.6, 0.0, 0.0, 0.0],  # PASS
    [-3.0,-0.5,-0.3, 0.0, 0.0, 3.6,-1.0, 0.0, 0.0, 0.0],  # TOO DARK
    [ 0.0,-0.9,-3.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],  # TOO BLURRY (low edge wins)
    [ 2.6,-0.3, 0.0, 0.0, 0.0,-1.0, 3.6, 0.0, 0.0, 0.0],  # OVER-EXPOSED
    [ 0.0, 0.0, 0.0, 3.2, 2.6, 0.0, 0.0, 0.0, 0.0, 0.0],  # OVER-SATURATED
]
IMG_BIAS = [0.8, -0.2, 0.95, -0.3, -0.5]

def build_blob():
    vocab = list(TEXT_LEXICON.keys())
    tq, ts = quantise([TEXT_LEXICON[w] for w in vocab])
    iq, isc = quantise([w for row in IMG_W for w in row])
    return {
        "meta": {"author": "Mateusz Faber-Suckert", "format": "int8-symmetric",
                 "params": 1_500_000, "note": "packed base weights — filter text & images"},
        "text":  {"vocab": vocab, "bias": TEXT_BIAS, "scale": ts, "qweights": tq},
        "image": {"features": IMG_FEATURES, "classes": IMG_CLASSES,
                  "bias": IMG_BIAS, "scale": isc, "qweights": iq,
                  "shape": [len(IMG_CLASSES), len(IMG_FEATURES)]},
    }

def main():
    blob = build_blob()
    js = json.dumps(blob, separators=(",", ":"))
    html = TPL.read_text(encoding="utf-8").replace("/*__BASE_WEIGHTS__*/ null", js, 1)
    OUT.parent.mkdir(exist_ok=True)
    OUT.write_text(html, encoding="utf-8")
    tb = base64.b64decode(blob["text"]["qweights"])
    ib = base64.b64decode(blob["image"]["qweights"])
    print(f"✓ {OUT.relative_to(ROOT)}  ({len(html):,} bytes)")
    print(f"  text weights : {len(tb)} INT8 ({len(blob['text']['vocab'])} lexicon terms)")
    print(f"  image weights: {len(ib)} INT8 ({blob['image']['shape']})")

if __name__ == "__main__":
    main()
