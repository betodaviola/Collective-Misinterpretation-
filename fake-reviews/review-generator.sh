#!/bin/bash

###This script generates fake reviews that can be using for testing our piece by simulating a like audience. Please modify the name of the document in the OUTPUT variable below before every use so the previous document is not override 


#Variables
MODEL="deepseek-r1:14b"
OUTPUT="fake-reviews/balanced-reviews.txt"

#now it will ask the user for other variables (easier to change test parameters on the fly)
echo "How many reviews would you like?"
read TOTAL_COUNT

while true; do
    echo "What percentage of these $TOTAL_COUNT reviews are POSITIVE (0–100)?"
    read POS_PERCENT

    # Check if it's a valid number between 0 and 100
    if [[ "$POS_PERCENT" =~ ^[0-9]+$ ]] && (( POS_PERCENT >= 0 && POS_PERCENT <= 100 )); then
        break  # valid input, exit loop
    else
        echo "Invalid input. Please enter a number between 0 and 100."
    fi
done

POSSIBLE_NEG=$((100 - POS_PERCENT))

while true; do
    echo "What percentage of these $TOTAL_COUNT reviews are NEGATIVE (0–$POSSIBLE_NEG)? The rest will be neutral reviews?"
    read NEG_PERCENT

    # Check if it's a valid number between 0 and 100
    if [[ "$NEG_PERCENT" =~ ^[0-9]+$ ]] && (( NEG_PERCENT >= 0 && NEG_PERCENT <= POSSIBLE_NEG )); then
        break  # valid input, exit loop
    else
        echo "Invalid input. Please enter a number between 0 and $POSSIBLE_NEG."
    fi
done

NEU_PERCENT=$((POSSIBLE_NEG - NEG_PERCENT))

positive_count=$((TOTAL_COUNT * POS_PERCENT / 100))
negative_count=$((TOTAL_COUNT * NEG_PERCENT / 100))
neutral_count=$((TOTAL_COUNT * NEU_PERCENT / 100))

echo "Generating $positive_count positive, $negative_count negative, and  $neutral_count neutral reviews..."

#define start time to calculate total time for n scripts
start_time=$(date +%s)

#generate reviews
for i in $(seq 1 $TOTAL_COUNT); do
    echo "Generating review $i of $TOTAL_COUNT..."

    if [ "$positive_count" -gt 0 ]; then
        TONE="positive"
        ((positive_count--))
    elif [ "$neutral_count" -gt 0 ]; then
        TONE="neutral"
        ((neutral_count--))
    else
        TONE="negative"
        ((negative_count--))
    fi

    PROMPT="You are an audience member at a contemporary music concert. While a short piece for viola and fixed media is being executed, you are invited to write a 100 to 300 words review of said piece, describing what you hear. Your description can range from from technical terms (e.g., melody, harmony, timbre, genre, style) to more abstract portrayals (e.g., mood, emotions, feelings), or stick to general impressions. Your review can also include your personal opinion about the piece, which, on this case, is $TONE. Do not mention the title of the piece or any names of the artists involved. Do not include a title or header of any kind to the review and start directly with the content."

    echo -e "<review>" >> "$OUTPUT"
    ollama run $MODEL --hidethinking "$PROMPT" >> "$OUTPUT"
    echo -e "</review>" >> "$OUTPUT"
done


#calculate total review generation time...
end_time=$(date +%s)
duration=$((end_time - start_time))
# and the avarage per review
avg_time=$((duration / TOTAL_COUNT))

echo "Done. $TOTAL_COUNT reviews saved to $OUTPUT. Process completed in ${duration}s. (${avg_time}s per review using $MODEL)"
