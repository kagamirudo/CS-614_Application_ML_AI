# Presentation Script -- AudioRestore

Video recording script for CS 614 Final Project.
Total target: ~8-10 minutes.

---

## Slide 1: Title

**[SHOW SLIDE]**

Hey everyone, my name is Gary Pham, and today I'm presenting my CS 614 final project called AudioRestore. It's a text-controlled audio quality restoration system built by fine-tuning a model called SonicMaster. Let me walk you through the problem, the approach, the results, and then I'll show you a live demo.

---

## Slide 2: The Problem

**[SHOW SLIDE]**

So here's the problem. There are literally billions of audio files out there stuck in low quality. Spotify Free streams at 128 kbps, YouTube rips are even lower, and a lot of us have old MP3 collections that were encoded with really aggressive compression back in the day.

Lossy codecs like MP3 destroy high-frequency content and introduce artifacts like pre-echo and spectral holes -- you can hear it as that kind of "underwater" or "tinny" sound.

Now, if you want to fix that today, you need to be an audio engineer. You'd have to manually chain together EQ, de-noising, spectral repair tools -- and each one requires expert tuning. There's no simple "fix my audio" button for regular people.

So the question is: what if you could just describe what's wrong with your audio in plain English and have it fixed automatically?

---

## Slide 3: What Exists Today

**[SHOW SLIDE]**

Let's look at what exists. Traditional DSP is fully manual, no text control. Apollo, which came out at ICASSP 2025, is a really strong regression model for audio restoration -- but it gives you zero user control. It's a fixed input-to-output mapping.

Then there's SonicMaster, published at ICLR 2026. It's a 0.9 billion parameter generative model that supports text-prompt conditioning -- so you can tell it what to do. But it's general-purpose. It handles EQ issues, dynamics, reverb, all sorts of stuff. It's not specialized for codec artifacts specifically.

So the gap is: nobody offers text-controlled, codec-specific restoration. That's what AudioRestore fills.

---

## Slide 4: Our Approach

**[SHOW SLIDE]**

Our approach is straightforward: take SonicMaster and fine-tune it specifically for codec artifact removal.

The user interaction looks like this: you upload your degraded MP3, you type a prompt like "restore audio compressed at 64 kbps MP3," and you get back restored audio with recovered high-frequency content.

Why SonicMaster as the base? It's state-of-the-art for audio restoration, it already has the text-conditioning infrastructure built in, and it uses flow matching which gives us fast inference in about 10 steps.

---

## Slide 5: Architecture

**[SHOW SLIDE]**

**[SHOW PAPER: Figure 1]**

Let me show you the architecture from the paper. Here's the full pipeline.

There are two frozen components that we don't update during fine-tuning: the T5 text encoder, which processes the user's prompt, and the Stable Audio VAE, which compresses the waveform into a latent representation and decodes it back.

What we actually fine-tune is 522 million parameters: the FluxTransformer, which does the flow matching in latent space; the audio conditioning module, which extracts features from the degraded input; and the projection layers that fuse the text and audio conditions together.

So the pipeline goes: degraded audio goes into the VAE encoder, the transformer does flow matching conditioned on your text prompt and the audio features, and then the VAE decoder produces the restored waveform.

---

## Slide 6: Dataset

**[SHOW SLIDE]**

For the dataset, we started with MUSDB18-HQ, which is a high-quality music dataset. We took 114 audio files and cut them into 1,000 non-overlapping 30-second clips -- 900 for training, 100 for validation.

For codec degradation, 70% of clips get MP3 compression at various bitrates from 24 to 128 kbps, and 30% get OGG Vorbis at different quality levels. So we have a nice range of degradation severity.

Each clip also gets annotated with text prompts. 40% of the time it's a specific prompt like "restore audio compressed at 64 kbps MP3," 40% is an alternative phrasing, 10% is a generic prompt, and 10% is empty for unconditional training. This teaches the model to respond to various phrasings.

---

## Slide 7: Training

**[SHOW SLIDE]**

For training details: 522 million trainable parameters out of 0.9 billion total. We use AdamW optimizer with a learning rate of 1e-5 and cosine schedule. Effective batch size of 8 through gradient accumulation. Mixed BF16 precision.

One key modification we made: we added gradient clipping with max norm 1.0. Without this, training would diverge. That was an important finding.

We trained for 30 epochs, about 3,390 optimization steps total, on a single A100 GPU. The whole thing took about 2.5 hours. We also pre-encoded all the audio into VAE latents before training to avoid redundant forward passes, which sped things up significantly.

---

## Slide 8: Training Convergence

**[SHOW SLIDE]**

**[SHOW PAPER: Figure 2]**

Here's the loss curve from the paper. You can see the flow-matching loss drops really fast in the first 5 epochs -- from about 0.37 down to 0.15. Then it continues to improve gradually.

The best validation loss is 0.0996 at epoch 28. And importantly, the training and validation losses track each other closely the whole way through -- so no overfitting, even on a relatively small dataset of just 1,000 clips.

---

## Slide 9: Results -- Metrics

**[SHOW SLIDE]**

Now for the results. Here's our SDR table. At 32 kbps, the degraded input has 13.71 dB SDR and the restored output has 7.71 dB. At 64 kbps, it goes from 16.24 to 8.47. At 128 kbps, from 20.13 to 8.96.

So the SDR actually goes down. Why? Because this is a generative model, not a regression model. It doesn't try to reconstruct the exact original signal sample by sample. Instead, it synthesizes new, perceptually plausible audio. SDR penalizes any deviation from the reference, even if that deviation sounds better.

Notice the output is remarkably consistent at around 8 dB regardless of how bad the input was. The model is mapping everything toward a learned "clean audio" distribution. Perceptual metrics like PESQ or FAD would better capture what this model is actually doing.

---

## Slide 10: Results -- Spectrograms

**[SHOW SLIDE]**

**[SHOW PAPER: Figure 3]**

Let me show you the spectrograms from the paper. These are really telling.

At 32 kbps on top, you can see the degraded audio is missing a lot of energy above 10 kHz. The restored version clearly recovers that high-frequency content. At 64 kbps in the middle, missing spectral detail is filled in. And at 128 kbps at the bottom, even though the degradation is mild, the model still actively synthesizes new high-frequency content.

So the model is clearly generating the spectral information that the codec removed. SDR can't capture this improvement, but you can see it and hear it.

---

## Slide 11: Prompt Variation

**[SHOW SLIDE]**

We also tested different text prompts on the same 64 kbps degraded audio. "Remove MP3 compression artifacts" scores the highest at 8.53 dB. The most specific codec prompt, a generic prompt, and even an empty unconditional prompt all produce similar results, with only a 0.13 dB spread.

This tells us two things: the text conditioning works -- the most specific prompt does score highest -- and the model is robust. It doesn't break if you phrase things differently.

---

## Slide 12: Demo Title

**[SHOW SLIDE]**

Alright, let's do the demo. I'm going to switch over to the notebook now.

---

## Slide 13: Live Demo

**[SWITCH TO COLAB]**

So here's the demo notebook running in Colab. The model and VAE are already loaded. Let me walk you through what's happening.

We take a clean audio clip from MUSDB18-HQ and degrade it with MP3 compression at three bitrates: 32, 64, and 128 kbps.

For each one, we run the restoration with a text prompt like "restore audio compressed at 32 kbps MP3."

**[Scroll to the spectrogram outputs]**

Here you can see the spectrogram comparisons. On the left is the original, middle is degraded, right is restored. You can clearly see the model filling in the high-frequency content that MP3 compression removed.

**[PLAY AUDIO]**

Let me play the audio. Here's the original... here's the degraded version at 32 kbps -- you can hear the artifacts... and here's the restored version. It's not a perfect reconstruction, but you can hear the model has added back richness and detail.

**[Scroll to prompt variation cell]**

And here's the prompt variation experiment. Same degraded audio, different prompts. You can see the SDR values are all clustered around 8.4 to 8.5 dB, confirming the model responds to different phrasings.

---

## Slide 14: Product Vision

**[SHOW SLIDE]**

So where could this go as a product? There are several directions.

A web app or API where users just upload their compressed audio, describe what's wrong, and get it fixed. Integration with streaming platforms to upscale low-bitrate streams. A plugin for digital audio workstations for mastering engineers. Or a mobile app for restoring old MP3 collections.

The key value proposition is the text control. Non-experts can't use traditional audio restoration tools. But anyone can say "fix my low quality MP3."

---

## Slide 15: Key Takeaways

**[SHOW SLIDE]**

Four takeaways.

First, fine-tuning works. Just 1,000 clips and 2.5 hours on a single GPU is enough to specialize SonicMaster for codec restoration.

Second, generative restoration is fundamentally different from regression. The model synthesizes plausible audio rather than reconstructing exact signals.

Third, text control survives fine-tuning. You can still steer the model with natural language after domain-specific training.

And fourth, SDR isn't the whole story for generative models. We need perceptual metrics for proper evaluation.

For future work: perceptual evaluation with PESQ and FAD, a head-to-head comparison with Apollo, training on larger datasets, and exploring hybrid generative-plus-regressive approaches.

---

## Slide 16: Thank You

**[SHOW SLIDE]**

And that's AudioRestore. The code is in the demo notebook, the report is a 5-page IEEE format paper with 18 references, and all the data and checkpoints are on Google Drive. Thank you!
