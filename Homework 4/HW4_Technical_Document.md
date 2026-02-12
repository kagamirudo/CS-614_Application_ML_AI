## 1. Description of the Pretrained Model

### 1.1 Architecture

For this assignment I used the **Faster R‑CNN with ResNet‑50 FPN backbone** provided by `torchvision` (`fasterrcnn_resnet50_fpn` with `FasterRCNN_ResNet50_FPN_Weights.DEFAULT`).

At a high level, the architecture consists of:

- **Backbone (ResNet‑50 + FPN)**  
  - A deep residual convolutional network (ResNet‑50) extracts feature maps from the input image.  
  - A **Feature Pyramid Network (FPN)** takes intermediate feature maps from the backbone and builds a multi‑scale feature pyramid, which helps detect both small and large objects.

- **Region Proposal Network (RPN)**  
  - Slides small convolutional filters over the FPN feature maps.  
  - At every spatial location it predicts:
    - A set of **anchor boxes** (with different aspect ratios and scales).  
    - **Objectness scores** (object vs. background) and **box regression offsets**.  
  - The RPN produces a set of **region proposals** (candidate bounding boxes that may contain objects).

- **RoI Pooling / RoI Align + Detection Head**  
  - Region proposals are projected back onto the FPN feature maps.  
  - For each proposal, **RoIAlign** extracts a fixed‑size feature representation.  
  - These RoI features are passed through fully connected layers that output:
    - A **classification distribution** over all object classes plus background.  
    - **Bounding‑box regression deltas** to refine the proposal boxes.

During inference, the model:

1. Runs the backbone + FPN on the input image.  
2. Uses the RPN to generate proposals.  
3. Applies the detection head to each proposal.  
4. Applies **non‑maximum suppression (NMS)** per class to remove highly overlapping boxes.  
5. Returns final **bounding boxes, class labels, and confidence scores**.

### 1.2 Training Dataset

The pretrained weights `FasterRCNN_ResNet50_FPN_Weights.DEFAULT` were trained on the **COCO (Common Objects in Context)** dataset.

- **Type of dataset**: Large‑scale everyday object detection dataset.  
- **Number of classes**: 91 object categories in the original COCO annotations, 80 commonly used categories in many implementations.  
- **Examples of classes**: person, car, bicycle, dog, cat, chair, traffic light, etc.  
- **Annotations**: Each image has:
  - One or more objects annotated with bounding boxes.  
  - Category labels and instance IDs.  
- **Image characteristics**:
  - Complex, real‑world scenes with multiple objects.  
  - Large variation in scale, pose, lighting, and occlusion.

Because the model is trained on COCO, it can detect a wide variety of common objects in generic scenes, which is suitable for the two test images used in this assignment.

---

## 2. 2 × 2 Grid of Images

I selected **two test images** from my own collection:

- **Image 1**: *(brief description, e.g., “street scene with pedestrians and cars”)*  
- **Image 2**: *(brief description, e.g., “indoor scene with a table and objects”)*  

Both images were loaded with PIL, converted to tensors, and preprocessed using the model’s default `weights.transforms()` before inference.

Below is a **2 × 2 grid** satisfying the requirement:

- Row 1: Original input images.  
- Row 2: Detections for the same images with color‑coded bounding boxes.

|                        | **Image 1**                      | **Image 2**                      |
|------------------------|----------------------------------|----------------------------------|
| **Original Input**     | ![Image 1 Original](images/1.jpg)  | ![Image 2 Original](images/2.jpg)  |
| **With Detections**    | ![Image 1 Boxes](image1_boxes.png) | ![Image 2 Boxes](image2_boxes.png) |

**Note:**  
Replace `image1.png`, `image2.png`, `image1_boxes.png`, and `image2_boxes.png` with the actual filenames you saved from the notebook (e.g., exports from `matplotlib` or saved tensors converted back to PIL images).

For the detections:

- I ran the model in evaluation mode with `model.eval()`.  
- I applied a score threshold (see next section) to filter predictions.  
- I used `draw_bounding_boxes` from `torchvision.utils`:
  - Each box is drawn with a **class‑specific color** (random but consistent per class).  
  - The plotted images were converted to NumPy arrays and displayed with `matplotlib`.

---

## 3. Additional Details, Resources, and Threshold Choice

### 3.1 Pre‑processing and Post‑processing

- **Pre‑processing**  
  - Images were loaded using **PIL**.  
  - Each image was converted to a tensor using `torchvision.transforms.functional.pil_to_tensor`.  
  - The tensor was passed through `weights.transforms()` which:
    - Converts to float and scales to \([0, 1]\).  
    - Normalizes using the same mean and standard deviation used when training the model.  
    - Handles resizing and any other required transforms.

- **Post‑processing**  
  - The model returns, for each image:
    - `boxes` (bounding‑box coordinates)  
    - `labels` (integer class indices)  
    - `scores` (confidence values between 0 and 1)  
  - I then:
    - Filtered detections using a chosen **confidence threshold**.  
    - Mapped `labels` to their class names using `weights.meta["categories"]`.  
    - Collected and logged:
      - Class name  
      - Bounding‑box coordinates  
      - Confidence score  
    - Passed the filtered boxes and labels to `draw_bounding_boxes` to produce the final annotated images.

### 3.2 Threshold Choice and Rationale

I used a **score threshold of 0.8**:

- **Why 0.8?**
  - Lower thresholds (e.g., 0.3–0.5) produced many boxes, including some that were clearly false positives or very uncertain detections.  
  - A higher threshold (0.8) keeps only detections where the model is relatively confident.  
  - For my two test images, a threshold around 0.8 still preserved the main, visually obvious objects (e.g., people, cars, and large objects) while removing most spurious detections.

- **Effect of different thresholds**
  - **Threshold < 0.5**:  
    - Many more boxes on the image.  
    - Some overlapping and clearly wrong detections, making the visualization cluttered.  
  - **Threshold ≈ 0.7–0.8**:  
    - A good balance between **precision** and **readability** of the visualization.  
    - The boxes mostly correspond to objects that are clearly visible.  
  - **Threshold > 0.9**:  
    - Very few detections; some real objects with slightly lower confidence are dropped.

Given the goal of this assignment—to visualize clear, high‑quality detections on my own images—I chose **0.8** as a reasonable compromise. It preserves the most important objects while avoiding clutter and obvious false positives, which makes the 2×2 grid easy to interpret.

### 3.3 Resources Used

- **PyTorch tutorial (torchvision detection/finetuning)**  
  - `https://pytorch.org/tutorials/intermediate/torchvision_tutorial.html`  
- **Torchvision visualization utilities**  
  - Example usage of `draw_bounding_boxes` and related functions.  
  - `https://pytorch.org/vision/main/auto_examples/others/plot_visualization_utils.html`  
- **Official PyTorch / Torchvision documentation** for:
  - `torchvision.models.detection.fasterrcnn_resnet50_fpn`  
  - `FasterRCNN_ResNet50_FPN_Weights`  
  - `draw_bounding_boxes` and image transforms.

