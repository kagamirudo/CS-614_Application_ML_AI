# Applications

This folder contains the **Apollo** music-restoration app and the **music.ipynb** notebook: input a compressed track (e.g. MP3) and get a restored WAV with better perceived quality.

---

## Model and restoration theory

### What is audio restoration?

**Audio restoration** is the task of recovering **clean (or higher-quality) audio** from **degraded** input. Here, the main degradation is **lossy codec compression** (e.g. MP3 at low bit rates). The goal is to reduce artifacts (e.g. blurriness, “underwater” tone, pre-echo) and improve perceived quality while keeping the content and structure of the music.

- **Why it’s hard:** Compression throws away information. The model must *infer* missing or distorted parts (especially in mid and high frequencies) from context and from what is still preserved (often low frequencies and overall envelope).
- **Training setup:** Apollo is trained with a **GAN** (generator + discriminator): the generator produces restored audio, and the discriminator tries to tell real vs. restored. That balances **distortion** (e.g. MSE) with **perception** (sounding natural and high quality).

### Why work in the frequency domain?

Codec artifacts are largely **frequency-dependent**: mid and high frequencies are more distorted than low ones. Modeling in the **spectrogram** (STFT) domain lets the network:

- Focus capacity on fixing the bands that are most damaged.
- Preserve low-frequency content and only “fill in” or clean higher bands.
- Use structure across frequency and time (e.g. harmonic relations, temporal continuity).

Apollo therefore operates on **complex Short-Time Fourier Transform (STFT)** frames: it modifies the spectrum and then converts back to waveform with the inverse STFT (iSTFT).

### How Apollo works (high level)

1. **Input waveform → STFT**  
   The waveform is converted to a complex spectrogram (e.g. 20 ms windows, 50% overlap at 44.1 kHz). Each time frame has many frequency bins.

2. **Frequency band split (gain–shape)**  
   The spectrum is split into **80 sub-bands**. For each band, Apollo uses a **gain–shape** representation:
   - **Shape:** the complex values in that band, normalized by the band’s energy (so unit “direction” in the complex plane).
   - **Gain:** the band’s energy (magnitude/power) over time.  
   This separates “what the spectrum looks like” (shape) from “how loud that band is” (gain), which helps the model learn stable, interpretable features.

3. **Feature extraction**  
   For each band, the inputs are:
   - real and imaginary parts of the normalized spectrum (shape),
   - log of the band power (gain).  
   Small per-band networks (normalization + 1×1 conv) map these to a shared **feature dimension** (e.g. 256). So we get a tensor of shape (batch, bands, features, time).

4. **Band–sequence modeling (BSNet)**  
   Apollo then applies several **BSNet** blocks. Each block does two things:
   - **Across-band modeling (Roformer):** at each time step, a transformer with **rotary positional embeddings** mixes information **across the 80 bands**. That captures how different frequency regions should co-vary (e.g. harmonics, formants).
   - **Along-time modeling (ICB):** 1D convolutions along the **time** axis for each band. That enforces temporal smoothness and context (e.g. no sudden clicks, stable pitch).

   So the model jointly refines **which frequencies** are present and **how they evolve in time**.

5. **Per-band output heads → iSTFT**  
   For each band, a small head (normalization, conv, GLU) predicts **real and imaginary** updates, giving a **complex subband spectrum**. All bands are concatenated back into one spectrogram, and **inverse STFT** reconstructs the **restored waveform**.

### Summary

- **Input:** Compressed (e.g. MP3) or otherwise degraded waveform.
- **Representation:** STFT → 80 bands, each as gain + shape.
- **Processing:** Band–sequence blocks (cross-band transformer + temporal conv) refine features.
- **Output:** Predicted complex spectrum → iSTFT → restored waveform.

Apollo was trained on **MUSDB18-HQ** and **MoisesDB** with simulated MP3 at various bit rates and a GAN loss, so it learns to restore music while keeping natural timbre and structure. At inference we run the **generator** only; no discriminator is used.

**References:** [Apollo (Li & Luo, ICASSP 2025)](https://arxiv.org/abs/2409.08514), [Hugging Face model](https://huggingface.co/JusperLee/Apollo), [Apollo README](Apollo/README.md).

---

## Contents

- **Apollo/** – Apollo model and `look2hear` code (band-sequence music restoration, [Hugging Face](https://huggingface.co/JusperLee/Apollo)).
- **music.ipynb** – Notebook: load a track → run Apollo → save restored WAV. Uses chunked inference and overlap-add to avoid GPU OOM and seam artifacts.
- **asserts/** – Your input/output audio (e.g. `input.mp3`, `restored_output.wav`).
- **create_apollo_kernel.sh** / **clean_apollo_env.sh** – Scripts to create or remove the Apollo Jupyter kernel (see below).
- **Makefile** – `make apollo-kernel`, `make apollo-clean`, `make apollo-clean-all`.

## Quick start

From the **repository root**:

```bash
make apollo-kernel    # Create conda env in /opt/apollo-env and register "Python (Apollo)" kernel (ROCm GPU)
```

Then open **Applications/music.ipynb**, choose the **Python (Apollo)** kernel, and run the cells. Put your input file in `Applications/asserts/` (e.g. `input.mp3`) and set `input_track` in the notebook.

- **Cleanup:** `make apollo-clean` removes the old named env and kernel; `make apollo-clean-all` also removes `/opt/apollo-env`.

---

## Git: “embedded git repository” warning

`Applications/Apollo` is a **clone of its own Git repo** (it has a `.git` inside). If you run `git add Applications/Apollo`, Git will warn that the outer repo does not track the contents of that inner repo, so people who clone your project won’t get the Apollo files unless you fix it.

You can either make Apollo part of your project or add it as a submodule.

### Option A – Apollo as part of this project (simplest)

You want all Apollo code committed in this repo. Clones get everything.

```bash
# From repo root
git rm --cached Applications/Apollo
rm -rf Applications/Apollo/.git
git add Applications/Apollo
git commit -m "Add Apollo as part of project"
```

After this, `Applications/Apollo` is normal tracked content (no submodule).

### Option B – Apollo as a Git submodule

You want to track the upstream Apollo repo and update it with `git submodule update`.

```bash
# From repo root
git rm --cached Applications/Apollo
git submodule add https://github.com/JusperLee/Apollo.git Applications/Apollo
git add .gitmodules Applications/Apollo
git commit -m "Add Apollo as submodule"
```

Anyone who clones your repo must run `git submodule update --init` to fetch Apollo.

---

Use **Option A** if you just want one repo with everything; use **Option B** if you want to pull upstream Apollo changes via the submodule.
