#!/usr/bin/env bash
#Dependencies: jq, ollama, stable-audio-tools

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
                    rm $download_dir/* summaries/* movements/*
                    echo "The contends of $download_dir/  and summaries/ have been deleted. Proceeding."
                    ##ADD THE OPTION TO CLEAN OTHER FOLDERS RELATED TO THE AI PARTS OF THE PROCESS LATER
                fi
                break;;
            No ) 
                echo "The piece will NOT run properly if folders are not clean. If this is not a test, please backup necessary local files, restart this script, and choose to clean local directories."
                break;;
        esac
    done

    sleep 0.5
    echo "If you already reset the form through the admin page, the performance can start."
    read -p "Press enter to play the first movement."
    echo "Playing..."
    pw-play audio-mov1.wav

    export OLLAMA_HOST=0.0.0.0:11434
    export OLLAMA_CONTEXT_LENGTH=16384
    export OLLAMA_MODELS=/mnt/storage/ollamaModels
    ollama serve > /dev/null 2>&1 &
    sleep 0.5
    ollama run $MODEL --hidethinking "say hi" > /dev/null 2>&1 & #warmup ollama as the movement plays for the first time

    pw-play audio-mov1.wav & #play again but now async while AI prepares the next movement
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

                sleep 0.5
                killall ollama #Need to make sure EVERYTHING in the gpu is available

                #starting generative proccess for the next movement
                gen_start=$(date +%s)
                
                source ~/stable-audio-tools/.venv/bin/activate #needs an outdated version of python to run
                huggingface-cli login --token "$(cat tk.txt)" #you also need to login into the hugginface account
                new_mov=$(PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python audio-gen.py "$output"| tail -n 1 | tr -d '\r\n') #tail and tr makes sure it ignores all outputs from the script except the last print() when assigning it to the variable
                deactivate #gets out from outdated python environment

                gen_end=$(date +%s)
                gen_dur=$((gen_end - gen_start))
                gen_total=$((gen_end - sum_start))
                echo "Done. ${new_mov} was created in ${sum_dur}s. ${gen_total}s after audience input was download."
                sleep 0.5
                
                read -p "Press enter to play the next movement."
                echo "Playing..."
                pw-play $new_mov

                export OLLAMA_HOST=0.0.0.0:11434
                export OLLAMA_CONTEXT_LENGTH=16384
                export OLLAMA_MODELS=/mnt/storage/ollamaModels
                ollama serve > /dev/null 2>&1 &
                sleep 0.5
                ollama run $MODEL --hidethinking "say hi" > /dev/null 2>&1 & #warmup ollama as the movement plays for the first time
                
                pw-play $new_mov & #play again but while AI prepares the next movement



                ############WORK ON AUTOPLAY THROUGH THE RIGHT INTERFACE###############
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

