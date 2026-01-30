# CS 614 - Programming Assignment 3: Technical Document  
## Transfer Learning for Image Classification (ResNet18 on CIFAR10)

---

## 1. Description of the Dataset Used to Pretrain ResNet (ImageNet)

The ResNet18 model we use is pretrained on **ImageNet-1K** (ILSVRC 2012).

- **Number of observations**
  - Training: **1,281,167** images  
  - Validation: 50,000 images  
  - Test: 100,000 images  

- **Number of features / input format**
  - Each observation is a **color image** of variable resolution, typically resized/cropped to **224×224 pixels** with **3 channels** (RGB).  
  - So each input has **224 × 224 × 3 = 150,528** pixel values (after preprocessing).  

- **Example of an image from ten different classes**  
  ImageNet-1K has **1,000 classes**. Ten example class names (from the 1,000) are:  
  - `tench` (fish), `goldfish`, `great_white_shark`, `tiger_shark`, `hammerhead`, `electric_ray`, `stingray`, `cock`, `hen`, `ostrich`.  
  *(The pretrained model was trained on the full ImageNet-1K set; we do not include actual ImageNet images here. Example images from these classes can be found in the official ImageNet/ILSVRC resources.)*

---

## 2. Description of the Non-Augmented ResNet18 Architecture

ResNet18 is a **18-layer** residual network (He et al., “Deep Residual Learning for Image Recognition”). The **non-augmented** (original) architecture, as in PyTorch TorchVision, is:

**List of layers (high level):**

| Stage   | Layer / block              | Description |
|--------|----------------------------|-------------|
| Stem   | `conv1`                    | Conv2d(3, 64, kernel_size=7, stride=2, padding=3) |
|        | `bn1`                      | BatchNorm2d(64) |
|        | `relu`                     | ReLU(inplace=True) |
|        | `maxpool`                  | MaxPool2d(kernel_size=3, stride=2, padding=1) |
| Layer1 | `layer1`                   | 2 × BasicBlock (64 channels) |
| Layer2 | `layer2`                   | 2 × BasicBlock (128 channels, stride 2 in first block) |
| Layer3 | `layer3`                   | 2 × BasicBlock (256 channels, stride 2 in first block) |
| Layer4 | `layer4`                   | 2 × BasicBlock (512 channels, stride 2 in first block) |
| Pool   | `avgpool`                  | AdaptiveAvgPool2d((1, 1)) |
| Head   | `fc`                       | Linear(512, **1000**) — 1000 classes for ImageNet |

Each **BasicBlock** contains: two 3×3 convolutions, BatchNorm, ReLU, and a residual connection (with optional 1×1 conv + BN for downsampling).  
Input size: **224×224×3**. Output: **1000** class logits (ImageNet).

*The exact layer-by-layer output can be reproduced by running `print(model)` in the notebook **before** replacing the final fully connected layer.*

---

## 3. Description of the CIFAR10 Dataset

- **Number of observations**
  - **Training:** 50,000 images  
  - **Testing:** 10,000 images  

- **Number of features**
  - Original: **32×32** RGB images → **32 × 32 × 3 = 3,072** pixel values per image.  
  - After our preprocessing: **224×224×3** (see below).  

- **List of features and their types**
  - **Features:** Pixel intensities for Red, Green, and Blue at each spatial location.  
  - **Types:** Numeric (float after normalization), in range [0, 1] after `ToTensor()`, then normalized (see below).  
  - **Label:** Integer class index 0–9 (categorical).  

- **Class names (10 classes)**  
  `airplane`, `automobile`, `bird`, `cat`, `deer`, `dog`, `frog`, `horse`, `ship`, `truck`.  

- **Example of an image from each class**  
  The notebook includes a figure showing **one training example per class** (see the cell “CIFAR10 Dataset Description”).  

- **Preprocessing**
  - Resize to **224×224** (to match ResNet/ImageNet input).  
  - **Training only:** `RandomHorizontalFlip(p=0.5)` for data augmentation.  
  - `ToTensor()`: scale pixels to [0, 1], shape (C, H, W).  
  - Normalize with ImageNet statistics:  
    - mean = [0.485, 0.456, 0.406], std = [0.229, 0.224, 0.225].  
  - **Testing:** No augmentation (Resize, ToTensor, Normalize only).  

- **Class priors**  
  The dataset is **balanced**:  
  - Training: 5,000 images per class → prior **1/10** per class.  
  - Test: 1,000 images per class → prior **1/10** per class.  

---

## 4. Design Choices

- **New (modified) architecture — what was changed**
  - **Frozen backbone:** All parameters of the pretrained ResNet18 initially have `requires_grad = False`.  
  - **Replaced final layer:** `model.fc` was changed from `Linear(512, 1000)` to `Linear(512, 10)` to match CIFAR10’s 10 classes.  
  - **Unfrozen for fine-tuning:** The last ResNet block (`model.layer4`) is then unfrozen (`requires_grad = True`) so it can adapt to CIFAR10. Layers `conv1` through `layer3` remain frozen.  
  - **Parameters trained:** The new final layer (fc) and **layer4** (last two BasicBlocks, 512 channels).  

- **Training and testing split**
  - **Training:** PyTorch CIFAR10 `train=True` → 50,000 images; DataLoader uses `shuffle=True`.  
  - **Testing:** PyTorch CIFAR10 `train=False` → 10,000 images; DataLoader uses `shuffle=False`.  
  - No validation split; we report training and testing metrics.  

- **Loss function**  
  **Cross-Entropy Loss** (`nn.CrossEntropyLoss`), standard for multi-class classification.  

- **Optimizer and hyperparameters**
  - **Optimizer:** Adam with two parameter groups:  
    - `model.fc.parameters()`: learning rate **1e-3**.  
    - `model.layer4.parameters()`: learning rate **1e-4** (smaller to avoid overwriting pretrained features).  
  - **Epochs:** 10.  
  - **Batch size:** 128.  
  - **Training:** Full dataset each epoch (`NUM_BATCHES = None`). Model and data are moved to GPU when available; mean loss per epoch is recorded and plotted.

- **Implementation notes (notebook)**
  - Device: `torch.device('cuda' if torch.cuda.is_available() else 'cpu')`; model and batches are moved to this device (works with ROCm on AMD GPUs as well as NVIDIA CUDA).  
  - Accuracy and confusion matrices: If predictions are missing (e.g. after kernel restart), the notebook can recompute them via batched evaluation over the train and test loaders.  
  - Success/failure examples: Predictions over the test set are computed in batches to avoid GPU out-of-memory; then one success and one failure example are plotted.  
  - Figures: Confusion matrices, success, and failure examples are saved to `confusion_matrices.png`, `success_example.png`, and `failure_example.png` in the notebook directory for use in this document.

---

## 5. Results

*Run the full notebook (all cells in order), then fill in the numeric results below and paste or embed the figures produced by the notebook.*

### 5.1 Training information

- **Training time:** 754.83 seconds (12.58 minutes).  
  *(Report the value printed as “Total training time” in the notebook.)*

- **Plot of loss vs epochs:**  
  *(Insert the “Training Loss vs Epochs” plot produced by the notebook.)*

### 5.2 Statistics (training and testing)

- **Accuracy**
  - Training accuracy: 99.47 %  
  - Testing accuracy: 90.74 %  

- **Confusion matrices**  
  *(Insert the figure saved as `confusion_matrices.png`: training set (left) and testing set (right).)*

### 5.3 Examples

- **Success case:**  
  *(Insert the image saved as `success_example.png`.)*

- **Failure case:**  
  *(Insert the image saved as `failure_example.png`.)*

---

## Summary

After running the full notebook:

1. Copy the **training time** and paste it into Section 5.1.  
2. Save the **loss vs epochs** plot and insert it in Section 5.1.  
3. Copy the **training and testing accuracies** into Section 5.2.  
4. Save the **two confusion matrix** figures and insert them in Section 5.2.  
5. Save the **success** and **failure** example images and insert them in Section 5.3.  

This yields a complete technical document that satisfies the assignment requirements.
