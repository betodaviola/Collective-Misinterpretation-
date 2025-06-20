#!/bin/bash

## Uses an AI model to summarize the audience reviews. Can be tested by using the fake reviews at the fake-reviews/ directory. 

#Dependencies: ollama
#If you do not have the specific models in your computer it will be automatically installed as the script runs, but it needs to be deleted manually later.
#You NEED to change the context window size according to the size of the document being summarized, or results will not be useful

#MODEL="deepseek-r1:14b" 
#MODEL="granite3.3:8b"
MODEL="mistral:7b"
INPUT="../fake-reviews/neutral-reviews.txt"
PROMPT="summarizing-prompts/sum-4.txt"
MODEL_NAME="${MODEL%%:*}" #Cannot figure out why this line is not working to remobe everything after the ':'. Will have to research later
INPUT_BASENAME=$(basename "$INPUT")
PROMPT_SUM=$(cat "$PROMPT")
PROMPT_BASENAME=$(basename "$PROMPT")
REVIEWS=$(cat "$INPUT")
#create directory for that specific model to keep things more organized and easy to compare
OUT_DIR="${PROMPT_BASENAME%%.*}"
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