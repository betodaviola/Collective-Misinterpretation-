#!/bin/bash
gen_start=$(date +%s)

PROMPT="prompt-mov0.txt"

source ~/stable-audio-tools/.venv/bin/activate #needs an outdated version of python to run
python image-gen2.py "$PROMPT"

#huggingface-cli login --token "$(cat ../tk.txt)" #you also need to login into the hugginface account
#PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python audio-gen.py "$PROMPT"| tail -n 1 | tr -d '\r\n' #tail and tr makes sure it ignores all outputs from the script except the last print() when assigning it to the variable

deactivate #gets out from outdated python environment
gen_end=$(date +%s)
gen_dur=$((gen_end - gen_start))
echo "Music and image created in ${gen_dur} seconds."
