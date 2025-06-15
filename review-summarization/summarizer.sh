#!/bin/bash

## Uses an AI model to summarize the audience reviews. Can be tested by using the fake reviews at the fake-reviews directory. 

#Despite being a weaker AI, mistral has proven to be a better option for this script. It is very fast and tends to breake less rules than deepseek

#Dependencies: ollama
#If you do not have the specific models in your computer it will be automatically installed as the script runs, but it needs to be deleted manually later.

MODEL="deepseek-r1:14b" #TOO SLOW. ALSO BREAKS PROMPT RULES ALMOST EVERY TIME.
#MODEL="granite3.3:8b" #COMPLETELY FAILED TO FOLLOW PROMPT RULES ALMOST EVERY TIME. IT ALSO ALLUCINATES OFTEN
#MODEL="mistral:7b"
INPUT="../fake-reviews/neutral-reviews.txt"
INPUT_BASENAME=$(basename "$INPUT")
OUTPUT="$MODEL-sum-$INPUT_BASENAME"
REVIEWS=$(cat "$INPUT")
#some keypoints only come accorss with CAPS and being repeated many times, like you are explaining it to a toddler. Prompting is the most frustrating part of this all. Some other prompts can be seen at the end of this script as an example.

PROMPT="You are an audience member at a contemporary music concert. While a short piece for viola and fixed media is being executed, you are invited to write a 100 to 200 words brief description of said piece, serving as an account of what you heard, in 2 to 3 short paragraphs.
Your descriptio should use the same language as the database below, and represent the avarage opinion of the database.
Do not include a title or header of any kind to the description and start directly with the content. Pretend like you are an audience member listening and taking notes in real time.
Your description should be uniquely focused on avaraging out what you can see on the database below, while pretending it is your own personal opinion. The language should be conversational regardless of how technical you choose it to be, so number or unumbered lists are not allowed.
This is the database:
$REVIEWS"

INPUT_N=$(grep "<input>" $INPUT | wc -l)
echo "Summarizing audience input. Total inputs to summarize: $INPUT_N"

# Delete contents of output file if it exists, or creates it if it doesn't
: > "$OUTPUT" 

#define start time to calculate total time for summarizing n reviews
start_time=$(date +%s)

#summarize it with the ollama model. Sometimes, lots of the rules are broken when too many audience inputs are loaded, since it is bigger than the context window of the AI. Despite the context being a problem, adding more details to prompt seems to make it better for mistral so I am trying that. A possible hack hack could be to resumarize the first output of the summarize (creating the first output as a temp file). Problem with this hack is that would make using slower and more powerfull models not possible since it would take too long between movements
ollama run $MODEL --hidethinking "$PROMPT" >> "$OUTPUT"


#calculate total review summarization time...
end_time=$(date +%s)
duration=$((end_time - start_time))

###maybe remove this line at the later stages of the project so it does not go to the music generator
echo "$INPUT_N reviews were summarized in ${duration}s." >> "$OUTPUT"

echo "Done. $INPUT_N reviews were summarized in ${duration}s, and saved to $OUTPUT."


#PROMPT="Write a summary of the database while following these rules:
#1- Keep it short (2 to 3 short paragraphs).
#2- DO NOT reveal directly or indirectly that it is a summarization. Rather pretend that you wrote the text while experiencing the performance mentioned in the database yourself.
#3- DO NOT use headers, bullet points, or lists for structure your text. The tone and structure should be conversational and informal.
#This is the database:
#$REVIEWS"

#PROMPT="After reading this whole prompt and paying fully attention to the described rules, please summarize the piece descriptions found in the database below into one single short description, and pretend that such summarization is its own account written by only one person (you) that was present in the described performance. 
#DO NOT include any headers or anything that would reveal you are summarizing other content, either by stating that your text is a summarization, or by using passive language and sentences that can suggest that the piece HAS BEEN HEARD  by someone else. For example, avoid language such as 'it has been said by', 'has garned reviews', 'people have said', 'critics have been made' etc). This also applies to sentences that say 'many admired this', or many felt that', as the word 'many' implies that this is not your opinion.
#Instead, describe as if it is the way YOU saw it, making every sentence seem like it came from you. Do not mention any opinion abou the piece without pretending that it came straight from your own experience. Someone reading your description needs to believe that you described the piece without having any other opinions about it available to you.
#Your final text should reflect the overall opinions and main points on the database as one unique and single description of the same style. 
#Try to condense your description into two short paragraphs. The language should be natural, as someone that attended to the concert and was describing a piece they heard to their best friend. Numbered or unumbered lists are not allowed, as your short descrition should sound informal and conversational.
#You don't need to structure your text in any way that would not be natural for someone listening and taking notes in real time (so, again, please NO LISTS OR LISTS SUMMARY). Your description will be input into an AI model that generates music in order to replicate it. The language should be conversational regardless of how technical you choose it to be, so number or unumbered lists are not allowed.
#This is the database:
#$REVIEWS"
