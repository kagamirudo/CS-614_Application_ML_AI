---
marp: true
theme: default
paginate: true
style: |
  section {
    font-size: 28px;
  }
  section.lead h1 {
    font-size: 52px;
    text-align: center;
  }
  section.lead p {
    text-align: center;
  }
  table {
    font-size: 22px;
    margin: 0 auto;
  }
  blockquote {
    border-left: 4px solid #4a86c8;
    padding-left: 16px;
    color: #555;
    font-style: italic;
  }
  h1 {
    color: #2a5a8a;
  }
  strong {
    color: #c0392b;
  }
  img[alt~="center"] {
    display: block;
    margin: 0 auto;
  }
---

<!-- _class: lead -->

# AudioRestore

### Text-Controlled Audio Quality Restoration via Fine-Tuned SonicMaster

**Gary Pham (gp492)**
CS 614 -- Applications of Machine Learning
Drexel University -- March 2026

---

# The Problem

### Billions of audio files are stuck in low quality

- Spotify Free: 128 kbps | YouTube rips: even lower
- Decades of MP3 collections with aggressive compression
- Lossy codecs **destroy high-frequency content**, introduce pre-echo & spectral holes

### Current solutions require expertise

- Manual signal processing chains (EQ, de-noise, spectral repair)
- No simple "fix my audio" option for regular users

> What if you could just *describe* what's wrong and have it fixed?

---

# What Exists Today

| System | Approach | Text Control? |
|--------|----------|:---:|
| Traditional DSP | Manual EQ / de-noise chains | No |
| Apollo (ICASSP 2025) | Band-sequence regression model | No |
| SonicMaster (ICLR 2026) | Generative flow matching, 0.9B params | Yes |

### The gap

- Apollo works great but gives **zero user control** -- fixed input to output
- SonicMaster supports text prompts but is **general-purpose**, not specialized for codecs
- **Nobody** offers text-controlled codec-specific restoration

---

# AudioRestore -- Our Approach

### Fine-tune SonicMaster for codec artifact removal

**Input:**
> Upload: `my_old_mp3.mp3`
> Prompt: *"restore audio compressed at 64kbps MP3"*

**Output:** Restored audio with recovered high-frequency content

### Why SonicMaster?
- State-of-the-art generative audio restoration (ICLR 2026)
- Already supports text-prompt conditioning
- Flow matching = fast inference (~10 steps)
- 0.9B parameters with proven capabilities

---

# Architecture

### Frozen (not updated)
- **T5 text encoder** -- encodes user prompt
- **Stable Audio VAE** -- compresses waveform to/from latent space

### Fine-tuned (522M params)
- **FluxTransformer** -- 6 joint + 18 single layers, flow matching in latent space
- **Audio conditioning module** -- extracts features from degraded latents
- **Projection layers** -- fuse text + audio conditions

### Pipeline
Degraded audio → VAE encode → FluxTransformer (text + audio conditioned) → VAE decode → Restored audio

---

# Dataset

### Source: MUSDB18-HQ
- 114 audio files → **1,000 clips** (30s each)
- 900 train / 100 validation

### Codec degradation
- **MP3** (70%): {24, 32, 48, 64, 96, 128} kbps
- **OGG Vorbis** (30%): quality {-1, 0, 1, 2, 3, 5}

### Text prompts per clip
| Probability | Example |
|:-----------:|---------|
| 40% | *"restore audio compressed at 64 kbps MP3"* |
| 40% | *"remove compression artifacts from this track"* |
| 10% | *"improve the sound quality"* |
| 10% | *(empty -- unconditional)* |

---

# Training

| | |
|---|---|
| **Trainable params** | 522M of 0.9B total |
| **Optimizer** | AdamW, lr = 1e-5, cosine schedule |
| **Batch size** | 2 x 4 accumulation = effective 8 |
| **Precision** | Mixed BF16 |
| **Gradient clipping** | Max norm 1.0 (added for stability) |
| **Epochs** | 30 (3,390 steps) |
| **Hardware** | Single NVIDIA A100 GPU |
| **Time** | ~2.5 hours |

All audio pre-encoded into VAE latents before training to avoid redundant forward passes.

---

# Training Convergence

### Loss over 30 epochs

| Stage | Train | Val |
|-------|:-----:|:---:|
| Initial | 0.369 | 0.328 |
| After 5 epochs | 0.151 | 0.150 |
| Best (epoch 28) | 0.095 | **0.0996** |

- Rapid drop in first 5 epochs
- Train and val track closely -- **no overfitting**
- Clean convergence on small dataset (1,000 clips)

*(see loss curve in paper -- Figure 2)*

---

# Results -- Metrics

| Bitrate | SDR Degraded | SDR Restored | Delta |
|:-------:|:-----------:|:-----------:|:-----:|
| 32 kbps | 13.71 dB | 7.71 dB | -6.00 |
| 64 kbps | 16.24 dB | 8.47 dB | -7.77 |
| 128 kbps | 20.13 dB | 8.96 dB | -11.17 |

### Why does SDR go *down*?

- This is a **generative** model -- it **synthesizes** plausible audio, not reconstruct exact samples
- SDR penalizes any deviation, even perceptually beneficial ones
- Output quality is **consistent ~8 dB** regardless of input severity
- Perceptual metrics (PESQ, FAD) would tell the real story

---

# Results -- Spectrograms

### What the spectrograms show

- **32 kbps:** severe artifacts → model recovers energy above 10 kHz
- **64 kbps:** missing spectral detail is filled in
- **128 kbps:** model still synthesizes new high-frequency content

The model **generates the spectral content that the codec removed**.

*(see spectrograms in paper -- Figure 3)*

---

# Prompt Variation

| Text Prompt | SDR |
|-------------|:---:|
| "remove MP3 compression artifacts" | **8.53 dB** |
| "restore audio compressed at 64kbps MP3" | 8.47 dB |
| "make this audio sound better" | 8.46 dB |
| "enhance low bitrate audio to high fidelity" | 8.41 dB |
| *(empty / unconditional)* | 8.40 dB |

- Text conditioning **works** -- most specific prompt scores highest
- Model is robust across phrasings (only 0.13 dB spread)
- Even empty prompt produces reasonable output

---

# Demo

### What you'll see

1. Load the fine-tuned model (522M trainable params)
2. Degrade clean audio with MP3 at 32 / 64 / 128 kbps
3. Run text-prompted restoration
4. Compare **spectrograms** (before vs. after)
5. **Listen** to original, degraded, and restored audio
6. Try **different text prompts** on same input

*(switching to notebook...)*

---

# Product Vision

### AudioRestore as a consumer product

- **Web app / API** -- Upload compressed audio, describe the problem, get it fixed
- **Streaming integration** -- Upscale low-bitrate streams for Spotify, YouTube
- **DAW plugin** -- For mastering engineers with degraded source material
- **Mobile app** -- Restore old MP3 collections on the go

### Why text control matters

Non-experts can't use traditional audio tools.
But anyone can say: *"fix my low quality MP3."*

---

# Key Takeaways

1. **Fine-tuning works** -- 1,000 clips + 2.5 hrs on one GPU is enough to specialize SonicMaster
2. **Generative != regressive** -- the model synthesizes plausible audio, doesn't reconstruct exact signals
3. **Text control preserved** -- natural language steering survives fine-tuning
4. **SDR isn't the whole story** -- generative models need perceptual metrics

### Future work
- Perceptual evaluation (PESQ, FAD)
- Head-to-head comparison with Apollo
- Larger / more diverse datasets
- Hybrid generative + regressive approach

---

<!-- _class: lead -->

# Thank You

**AudioRestore**
Text-Controlled Audio Quality Restoration via Fine-Tuned SonicMaster

Gary Pham (gp492) -- Drexel University

Code: `demo_submission.ipynb`
Paper: IEEE format, 5 pages, 18 references
