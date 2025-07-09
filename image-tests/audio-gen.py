# Run with: PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python audio-gen.py
#Still need to adjust number of steps accordingly

import torch
import torchaudio
import os
import gc
import sys
import json
import re
import time
from datetime import datetime
from einops import rearrange
from stable_audio_tools import get_pretrained_model
from stable_audio_tools.inference.generation import generate_diffusion_cond

# Read prompt file path from command-line argument
prompt_file = sys.argv[1]
with open(prompt_file, "r") as f:
    prompt_text = f.read().strip()

#clean memory cache before running
torch.cuda.empty_cache()
torch.cuda.ipc_collect()
gc.collect()

# Set device
device = "cuda" if torch.cuda.is_available() else "cpu"

# Load model
model, model_config = get_pretrained_model("stabilityai/stable-audio-open-1.0")
sample_rate = model_config["sample_rate"]
sample_size = model_config["sample_size"]

# Move model to GPU with half-precision (critical for memory!)
#model = model.to(torch.float16).to(device) #THIS IS THE BIGGEST CHANGE FROM THE DOCUMENTATION NECESSARY TO RUN ON RTX4060
model = model.to(device=device, dtype=torch.float16)

# Save model for reuse (optional)
model_path = "/mnt/storage/stableAudioModels"
os.makedirs(model_path, exist_ok=True)
torch.save(model.state_dict(), os.path.join(model_path, "pytorch_model.bin"))
with open(os.path.join(model_path, "config.json"), "w") as f:
    json.dump(model_config, f)

# Define prompt and duration
conditioning = [{
#    "prompt": "fast pace blues",
    "prompt": prompt_text,
    "seconds_start": 0,
    "seconds_total": 45
}]

start_time = time.time()
elapsed = time.time() - start_time

# Generate audio
with torch.no_grad(), torch.cuda.amp.autocast():
    output = generate_diffusion_cond(
        model,
        steps=150, #usually I keep it 200. biggest time increaser in between movements
        cfg_scale=12,
        conditioning=conditioning,
        sample_size=sample_size,
        sigma_min=0.2, #usually .3
        sigma_max=500,
        sampler_type="dpmpp-3m-sde",
        device=device
    )

# Move to CPU and free GPU memory
output = output.cpu()
torch.cuda.empty_cache()

# Post-process: reshape, normalize, convert
output = rearrange(output, "b d n -> d (b n)")
output = output.to(torch.float32)
output = output / torch.max(torch.abs(output))
output = output.clamp(-1, 1).mul(32767).to(torch.int16)

# Save to file
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
filename = f"audio_{timestamp}.wav"
torchaudio.save(filename, output, sample_rate)

#output path to use on bash script
print(f"\n✅ Audio saved as: {filename}")
print(f"🕒 Generation took {elapsed:.2f} seconds")

