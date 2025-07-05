#!/usr/bin/env bash
#Dependencies: jq, ollama

download_dir="local-inputs"
MODEL="mistral:7b"


function setup() {
    echo "Before proceeding, please make sure to open the admin webpage for the project and click the RESET button."
    echo "Follow the prompts on this terminal, and wait for the message after the Ollama warmup telling you that the piece can start."
    read -p "Press enter to continue"

    #This is a cool method for simple questions. Differently from using read -p, you don't need to sanitize it
    echo "Do you wanna clean the local directories? (1 or 2) Please backup important data first."
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                if [ -z "$( ls $download_dir )" && -z "$( ls summaries )" ]; then #-z checks if the length of a string is 0 (if string is either empty or null)
                    echo "$download_dir is empty. Proceeding."

                else
                    rm $download_dir/* summaries/*
                    echo "The contends of $download_dir/  and summaries/ have been deleted. Proceeding."
                    ##ADD THE OPTION TO CLEAN OTHER FOLDERS RELATED TO THE AI PARTS OF THE PROCESS LATER
                fi
                break;;
            No ) 
                echo "The piece will NOT run properly if folders are not clean. If this is not a test, please backup necessary local files, restart this script, and choose to clean local directories."
                break;;
        esac
    done


    echo "Please wait while we warmup the Ollama engine."
    start_warmup=$(date +%s)
    ollama run mistral:7b --hidethinking "Warmup!" > /dev/null 2>&1
    end_warmup=$(date +%s)
    warmup_dur=$((end_warmup - start_warmup))
    echo "Warmup time: ${warmup_dur} seconds."
#    sleep(0.5)
    echo "If you already reset the form through the admin page, the performance can start."
}

function watchdog() {
    lister="https://colmis.robertomochetti.com/file-lister.php"

    while true; do
        found_new_file=false
        files=$(curl -s -X POST -d "list" "$lister" | jq -r '.[]')
        for f in $files; do
            filename=$(basename "$f")
            if [ ! -f "$download_dir/$filename" ]; then
                echo "Downloading $filename..."
                curl -o "$download_dir/$filename" "https://colmis.robertomochetti.com/downloader.php?file=$filename"
                found_new_file=true
                #summarization process start
                sum_start=$(date +%s)

                input_n=$(grep "<input>" $download_dir/$filename | wc -l)
                echo "Summarizing audience input from $download_dir/$filename. Total inputs to summarize: $input_n"

                # Delete contents of output file if it exists, or creates it if it doesn't
                output="summaries/sum-${filename#input-}"
                : > "$output" 

                REVIEWS=$(cat "$download_dir/$filename")
                PROMPT_SUM=$(cat "summary-prompt.txt")
                PROMPT="$PROMPT_SUM
                Here is the database:
                $REVIEWS"


                ollama run $MODEL --hidethinking "$PROMPT" >> "$output"

                sum_end=$(date +%s)
                sum_dur=$((sum_end - sum_start))

                echo "Done. $input_n reviews were summarized in ${sum_dur}s, and saved to $output."









                break
            fi
        done

        if [ "$found_new_file" = false ]; then
            dots=("." ".." "...")
            for d in "${dots[@]}"; do
                echo -ne "\rLooking for new files$d   "
                sleep 1
            done
        fi
    done
}





setup
watchdog
echo "DONE"

