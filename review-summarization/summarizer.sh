#!/bin/bash

## Uses an AI model to summarize the audience reviews. Can be tested by using the fake reviews at the fake-reviews/ directory. 

#Dependencies: ollama
#
#You NEED to change the context window size according to the size of the document being summarized, or results will not be useful

##change the four important variables below appropriately
#1-model: If you do not have the specific models in your computer it will be automatically installed as the script runs, but it needs to be deleted manually later.
#MODEL="deepseek-r1:14b" 
#MODEL="granite3.3:8b"
MODEL="mistral:7b"

#2-input path: where is the database to be summarized
INPUT="../fake-reviews/neutral-reviews.txt"

#3-Prompt path: tells the AI all summarization rules
PROMPT="summarizing-prompts/sum-4.txt"

#4-Context window size: You NEED to set this accordingly on ollama's environmental variables, and the variable on this script is used only to keep things organized. If it is too much shorter than the number of tokens in the prompt+database, it will not summarize correctly and the output will be useless. If it is too big, it will take too long and for this specific piece we need the summarization to happen as quick as possible. Default value of 4096 is way too small for this. Other useful values: 8192, 12288, 16384, 20480, 24576 (multiples of 4096)
##great explanation on CW: https://deepai.tn/glossary/ollama/how-increase-ollama-context-size/
##Regardless of the good baseline found in the initial fases of the projects, get an avarage of tokens from real human audiences during the piece will be crucial to arrive to a final, safe value 
CW="16384"

##Now let it do the thing...
MODEL_NAME="${MODEL%%:*}" #Cannot figure out why this line is not working to remobe everything after the ':'. Will have to research later
INPUT_BASENAME=$(basename "$INPUT")
PROMPT_SUM=$(cat "$PROMPT")
PROMPT_BASENAME=$(basename "$PROMPT")
REVIEWS=$(cat "$INPUT")
#create directory for that specific model to keep things more organized and easy to compare
OUT_DIR="${PROMPT_BASENAME%%.*}_cw${CW}"
mkdir $OUT_DIR

OUTPUT="$OUT_DIR/$MODEL-$INPUT_BASENAME"

PROMPT="$PROMPT_SUM
Here is the database:
$REVIEWS"

INPUT_N=$(grep "<input>" $INPUT | wc -l)
echo "Summarizing audience input. Total inputs to summarize: $INPUT_N"

# Delete contents of output file if it exists, or creates it if it doesn't
: > "$OUTPUT" 

#define start time to calculate total time for summarizing n reviews
start_time=$(date +%s)

#summarize it with the ollama model
ollama run $MODEL --hidethinking "$PROMPT" >> "$OUTPUT"

#calculate total review summarization time...
end_time=$(date +%s)
duration=$((end_time - start_time))

###maybe remove this line at the later stages of the project so it does not go to the music generator
echo "$INPUT_N reviews were summarized in ${duration}s." >> "$OUTPUT"

echo "Done. $INPUT_N reviews were summarized in ${duration}s, and saved to $OUTPUT."