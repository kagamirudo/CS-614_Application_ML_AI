# Technical Document — HW5 Word2Vec (CBOW)

This report corresponds to `HW5.ipynb`.

## 1) Dataset description

- **Number of sentences**: 16
- **Number of unique words**: 52 (after lowercasing + regex tokenization)

**Examples of sentences**:

- What is the best time to call you tomorrow?
- What is the best hour to call you tomorrow?
- What is the best time to contact you tomorrow?
- What is the best hour to contact you tomorrow?
- Can we schedule a meeting for tomorrow morning?

## 2) Hyperparameter design choices

- **Window size**: 5 (`WINDOW_SIZE = 5`)
- **Embedding dimension**: 100 (`EMBED_DIMENSION = 100`)
- **Number of training epochs**: 500 (`MAX_EPOCHS = 500`)
- **Loss function**: cross-entropy (`nn.CrossEntropyLoss`)
- **Optimizer**: Adam with learning rate 0.05 (`torch.optim.Adam(lr=5e-2)`)
- **Batch size**: 32 (`BATCH_SIZE = 32`)

**Additional design choices**:

- **Tokenization**: simple regex tokenization with lowercasing (`re.findall(r"[a-z']+", ...)`) to drop punctuation like `?` and `.`.
- **Model**: CBOW (Continuous Bag of Words). Context embeddings are averaged and passed through a linear layer to predict the center word.
- **Synthetic dataset**: sentences were designed with overlapping contexts (e.g., `time`/`hour`, `call`/`contact`/`phone`, `meeting`/`appointment`, `car`/`automobile`, `quick`/`fast`) so the embedding space can learn useful similarity structure from a small corpus.

## 3) Results

- **Training plot**: produced in the notebook (loss vs epoch) and saved as `training_loss.png`.
- **Similar word tests**: printed in the notebook for the test set:
  `time, hour, call, contact, meeting, appointment, car, automobile, quick, fast`.

![Training loss](training_loss.png)

### How to generate the final filled-in report

Run `HW5.ipynb` in your course Python environment (where `torch` is installed). The last cell exports a completed report (including **final loss** and **similar-word outputs**) to:

- `report.md` (in the same directory as the notebook)

