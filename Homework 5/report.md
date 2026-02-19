# Technical Document — HW5 Word2Vec (CBOW)

## 1) Dataset description

- Number of sentences: 28
- Number of unique words: 66

Examples:
- What is the best time to call you tomorrow?
- What is the best hour to call you tomorrow?
- What is the best time to contact you tomorrow?
- What is the best hour to contact you tomorrow?
- Can we schedule a meeting for tomorrow morning?

## 2) Hyperparameter design choices

- Window size: 5
- Embedding dimension: 300
- Epochs: 500
- Loss: CrossEntropyLoss
- Optimizer: Adam (initial lr=0.025, linear decay to 0)
- Batch size: 32

Additional design choices:
- Tokenization: simple regex (`[a-z']+`) to drop punctuation and lowercase everything.
- Model: CBOW implemented as mean of context embeddings followed by a linear classifier.

## 3) Results

![Training loss](training_loss.png)

### Model Performance Metrics

- **Final Training Loss**: 0.0681

- **Top-1 Accuracy**: 95.40%
- **Top-3 Accuracy**: 100.00%
- **Top-5 Accuracy**: 100.00%
- **Perplexity**: 1.07


### Similar Word Tests (Cosine Similarity)

- **time**: `hour` (+0.817), `dog` (+0.357), `for` (+0.332), `you` (+0.231), `up` (+0.220)
- **hour**: `time` (+0.817), `you` (+0.460), `is` (+0.352), `works` (+0.309), `dog` (+0.283)
- **call**: `contact` (+0.777), `best` (+0.719), `good` (+0.371), `meeting` (+0.271), `afternoon` (+0.205)
- **contact**: `call` (+0.777), `best` (+0.553), `good` (+0.342), `have` (+0.269), `you` (+0.209)
- **meeting**: `he` (+0.622), `morning` (+0.590), `afternoon` (+0.524), `dog` (+0.434), `arrange` (+0.409)
- **appointment**: `purchased` (+0.554), `automobile` (+0.554), `she` (+0.554), `yesterday` (+0.554), `set` (+0.363)
- **car**: `bought` (+1.000), `last` (+0.471), `arrange` (+0.287), `meeting` (+0.253), `we` (+0.237)
- **automobile**: `purchased` (+1.000), `yesterday` (+1.000), `she` (+1.000), `plan` (+0.572), `appointment` (+0.554)
- **quick**: `fast` (+0.830), `brown` (+0.670), `leaps` (+0.484), `the` (+0.221), `over` (+0.206)
- **fast**: `quick` (+0.830), `brown` (+0.664), `jumps` (+0.469), `leaps` (+0.302), `over` (+0.207)
