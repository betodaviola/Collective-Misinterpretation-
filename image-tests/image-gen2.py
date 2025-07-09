import os
import sys
import torch
import time
import random
from datetime import datetime
from diffusers import StableDiffusionPipeline

# Read prompt file path from command-line argument
prompt_file = sys.argv[1]
with open(prompt_file, "r") as f:
    prompt_text = f.read().strip()

# === Custom model path ===
model_path = "/mnt/storage/stableDifusionModels/stable-diffusion-v1-4"
model_id = "CompVis/stable-diffusion-v1-4"  # You can try other models from Hugging Face

# ==== Setup ====
# Automatically download to this custom directory
os.makedirs(model_path, exist_ok=True)

# ==== Prompt ====
#prompt = prompt_text
prompt = "Rock band accompained by a Symphony Orchestra in the background"

# ==== Configurable Parameters ====
#output_resolution = (768, 768)              # Output image size (width, height)
inference_steps = 20                        # How many steps to generate image (10–50 is typical)
guidance_scale = 15                        # Higher = more faithful to prompt (try 5–15)

output_resolution = (1024, 576)              # Output image size (width, height)
#inference_steps = random.randint(10, 30)     # How many steps to generate image (10–50 is typical)
#guidance_scale = random.randint(5, 30)      # Higher = more faithful to prompt (try 5–15)

# ==== Load Model ====
print("\nLoading model...")
pipe = StableDiffusionPipeline.from_pretrained(
    model_id,
    torch_dtype=torch.float16,
    revision="fp16"
).to("cuda")

# Enable VRAM-saving options
pipe.enable_attention_slicing()     # Cuts memory use during attention
pipe.enable_model_cpu_offload()     # Moves unused parts of model to CPU

# Resize setting (used by some models; optional for SD v1.4)
pipe.scheduler.set_timesteps(inference_steps)

# ==== Generate Image ====
print(f"\nGenerating image with:")
print(f"- Resolution: {output_resolution[0]}x{output_resolution[1]}")
print(f"- Steps: {inference_steps}")
print(f"- Guidance scale: {guidance_scale}")
print(f"- Prompt: \"{prompt}\"")

start_time = time.time()
image = pipe(
    prompt=prompt,
    height=output_resolution[1],
    width=output_resolution[0],
    num_inference_steps=inference_steps,
    guidance_scale=guidance_scale
).images[0]
elapsed = time.time() - start_time

# ==== Save ====
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
filename = f"3generated_{timestamp}.png"
image.save(filename)

print(f"\n✅ Image saved as: {filename}")
print(f"🕒 Generation took {elapsed:.2f} seconds")
