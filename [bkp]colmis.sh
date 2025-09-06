#!/usr/bin/env bash
#Dependencies: jq, ollama, stable-audio-tools, wordcloud

download_dir="local-inputs"
MODEL="mistral:7b"
current_bkg=initial-assets/bkg-mov1.png #You need a first image already done to make it run smoothly

# Define some colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'

BOLD='\033[1m'
DIM='\033[2m'
UND='\033[4m' #underscore

RESET='\033[0m'

function dim_output() {
    "$@" 2>&1 | sed "s/^/$(printf '\033[2m')/;s/$/$(printf '\033[0m')/"
}
# A function to hold the important processing logic.
# This avoids code duplication and handles any file path given to it.
function process_file() {
    local input_file="$1"
    local filename=$(basename "$input_file")
    
    echo "Processing $filename..."
    # The output variable is set correctly for any input file
    local output="summaries/sum-${filename#input-}"

    #
    # A LOT OF VERY INMPORTANT CODE HAPPENS HERE WITH THE FILE
    bkg_path_file=$(mktemp)

    ( #image creation wrapped in a subshell to be full async
        dim_output wordcloud_cli --text $input_file --stopwords initial-assets/stop-words.txt --width 1800 --height 860 --mode RGBA --color "#ff0000" --background "#00000040" --imagefile images/cloud.png
        # (Assuming your variables are set)
        dim_output magick -quiet \
            \( "$current_bkg" -resize 1920x1080! \) \
            \( \
                \( -size 1800x120 -background 'rgba(0,0,0,0.7)' -fill yellow -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"The online form will open when the next movement starts" \) \
                images/cloud.png \
                -append \
            \) \
            -gravity center -composite \
            images/current-image.png

        sleep 20

        # Wait until the output file exists AND is not empty
        while [[ ! -s "$output" ]]; do
            sleep 0.5 # Wait half a second before checking again
        done

        word_n=$(cat "$output" | wc -w)

        cp $current_bkg images/current-image.png

        if (( word_n > 133 )); then
            split_file1=$(mktemp)
            split_file2=$(mktemp)

            # Count lines and words (preserving paragraphs)
            total_words=$(wc -w < "$output")
            half_words=$((total_words / 2))

            wc=0
            switch=0

            # Create the two split files while keeping line breaks
            while IFS= read -r line || [ -n "$line" ]; do
                for word in $line; do
                    if (( wc >= half_words )); then
                        switch=1
                    fi

                    if (( switch == 0 )); then
                        printf "%s " "$word" >> "$split_file1"
                    else
                        printf "%s " "$word" >> "$split_file2"
                    fi
                    ((wc++))
                done
                # preserve paragraph line breaks
                echo "" >> "$split_file1"
                echo "" >> "$split_file2"
            done < "$output"

            display_split1="\"$(cat $split_file1)..."
            display_split2="$(cat $split_file2)\""

            # Async image generation and display in the background
            (
                for part in "$display_split1" "$display_split2"; do
                    dim_output magick -quiet \
                        "$current_bkg" -resize 1920x1080! \
                        \
                        `# --- Place White Text Block ---` \
                        \( -size 1800x880 -background 'rgba(0,0,0,0.4)' -fill white -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"$part" \) \
                        -gravity center -geometry +0+60 -composite \
                        \
                        `# --- Place Yellow Title Block ---` \
                        \( -size 1800x120 -background 'rgba(0,0,0,0.7)' -fill yellow -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"The online form will open when the next movement starts. Your prompt:" \) \
                        -gravity North -geometry +0+80 -composite \
                        \
                        images/current-image.png
                    

                    sleep 27
                done
                dim_output cp $current_bkg images/current-image.png
                dim_output rm "$split_file1" "$split_file2"
            ) < /dev/null &

        else
            display_prompt="\"$(cat $output)\""
            dim_output magick -quiet \
                "$current_bkg" -resize 1920x1080! \
                \
                `# --- Place White Text Block ---` \
                \( -size 1800x880 -background 'rgba(0,0,0,0.4)' -fill white -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"$display_prompt" \) \
                -gravity center -geometry +0+60 -composite \
                \
                `# --- Place Yellow Title Block ---` \
                \( -size 1800x120 -background 'rgba(0,0,0,0.7)' -fill yellow -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"The online form will open when the next movement starts. Your prompt:" \) \
                -gravity North -geometry +0+80 -composite \
                \
                images/current-image.png
        fi
    ) < /dev/null &

        sum_start=$(date +%s)

    # ✅ This correctly assumes the file is in the download_dir
    input_n=$(grep "<input>" "$input_file" | wc -l)
    echo -e "${UND}Summarizing${RESET} audience input from $input_file. Total inputs to summarize: ${UND}$input_n${RESET}"

    # Delete contents of output file if it exists, or creates it if it doesn't
    output="summaries/sum-${filename#input-}"
    : > "$output" 

    # ✅ USE THE CORRECT FULL PATH HERE
    REVIEWS=$(cat "$input_file")
    PROMPT_SUM=$(cat "initial-assets/summary-prompt.txt")
    PROMPT="$PROMPT_SUM
    Here is the database:
    $REVIEWS"

    # checks if ollama is running. It should.
    if ! curl -sf http://localhost:11434/api/tags > /dev/null; then
        echo -e "${BOLD}Ollama is dead${RESET}. ${UND}RESUSCITATING${RESET} it now..."
        export OLLAMA_HOST=0.0.0.0:11434
        export OLLAMA_CONTEXT_LENGTH=16384
        export OLLAMA_MODELS=/mnt/storage/ollamaModels
        ollama serve > /dev/null 2>&1 &
        while ! curl -sf http://localhost:11434/api/tags > /dev/null; do
            sleep 0.1
        done
    fi

    #Summarizes user inputs
    ollama run $MODEL --hidethinking "$PROMPT" >> "$output"

    sum_end=$(date +%s)
    sum_dur=$((sum_end - sum_start))
    echo -e "Done. ${UND}$input_n${RESET} reviews were summarized in ${UND}${sum_dur}s${RESET}, and saved to $output."

    sleep 0.5
    #Need to make sure EVERYTHING in the gpu is available
    if [ -f /tmp/ollama.pid ]; then
        OLLAMA_PID_TO_KILL=$(cat /tmp/ollama.pid)
        echo "Stopping specific Ollama server (PID: $OLLAMA_PID_TO_KILL)..."
        kill $OLLAMA_PID_TO_KILL
        # Don't remove the file, because the script might loop or need it later
    else
        echo "Warning: Ollama PID file not found. Using killall as a fallback."
        killall ollama
    fi

    #starting generative proccess for the next movement
    gen_start=$(date +%s)
    
    source ~/stable-audio-tools/.venv/bin/activate #needs an outdated version of python to run

    #wrapped in a subshell to be full async
    bkg_path_file=$(mktemp)
    (
        python image-gen.py "$output" | tail -n 1 | tr -d '\r\n' > "$bkg_path_file"
    ) < /dev/null &

    dim_output huggingface-cli login --token "$(cat tk.txt)" #you also need to login into the hugginface account
    new_mov=$(PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python audio-gen.py "$output"| tail -n 1 | tr -d '\r\n') #tail and tr makes sure it ignores all outputs from the script except the last print() when assigning it to the variable
    deactivate #gets out from outdated python environment

    gen_end=$(date +%s)
    gen_dur=$((gen_end - gen_start))
    gen_total=$((gen_end - sum_start))
    echo -e "Done. ${new_mov} was created in ${UND}${sum_dur}s${RESET}. ${UND}${gen_total}s${RESET} after audience input was downloaded."
    sleep 0.5
    
    next_bkg_path=$(cat "$bkg_path_file") # <-- IMPORTANT: Read the path from the file
    rm "$bkg_path_file" # <-- Clean up the temp file
                    
    read -p "$(echo -e "${BOLD}Press enter to play the next movement.${RESET}")" < /dev/tty

    current_bkg="$next_bkg_path"
    dim_output magick -quiet \
        "$current_bkg" -resize 1920x1080! \
        \
        `# --- Place Yellow Title Block ---` \
        \( -size 1800x120 -background 'rgba(0,0,0,0.7)' -fill yellow -gravity center -font Adwaita-Sans-Bold -pointsize 45 caption:"Please fill the online form now" \) \
        -gravity Center -composite \
        \
        images/current-image.png

    play $new_mov
    break
}

function setup() {
    cp initial-assets/qr-code.png images/current-image.png
    sleep 0.5
    pqiv --fullscreen --hide-info-box --fade --scale-images-up --watch-files=on --fade-duration=1 images/current-image.png < /dev/null &
    sleep 0.5 # still needs time or it will transfer the background to your current workspace
    
    echo -e "Backup all local data from previous performances. For a successfull performance, select YES when asked about cleaning the local and online directories"
    read -p "$(echo -e "${BOLD}Press enter to continue${RESET}")"

    #This is a cool method for simple questions. Differently from using read -p, you don't need to sanitize it
    echo "Do you wanna clean the local directories? (1 or 2) Please backup important data first."
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                if [ -z "$( ls $download_dir )" ] && [ -z "$( ls summaries )" ]; then #-z checks if the length of a string is 0 (if string is either empty or null)
                    echo "$download_dir is empty. Proceeding."

                else
                    dim_output rm $download_dir/* summaries/* movements/* images/*
                    echo "The contents created on previous runs of the piece have been deleted. Proceeding."
                    ##ADD THE OPTION TO CLEAN OTHER FOLDERS RELATED TO THE AI PARTS OF THE PROCESS LATER
                fi
                break;;
            No ) 
                echo -e "${BOLD}${RED}WARNING:${RESET}${BOLD} The piece will NOT run properly if folders are not clean. If this is not a test, please backup necessary local files, restart this script, and choose to clean local directories.${RESET}"
                break;;
        esac
    done
    echo "Do you wanna reset the online directories before starting the piece? (1 or 2). A copy will be available at your online hosting service."
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                curl -w "\n" -X POST -d "btnStatus=reset" https://colmis.robertomochetti.com/admin/form-handler.php
                curl -w "\n" -X POST -d "" https://colmis.robertomochetti.com/admin/input-backup.php
                echo "Online directories reset."
                break;;
            No ) 
                echo -e "${BOLD}${RED}WARNING:${RESET}${BOLD} The piece will NOT run properly if online directories are not clean. If this is not a test, please restart this script, and choose to reset online directories.${RESET}"
                break;;
        esac
    done

    sleep 0.5
    read -p "$(echo -e "${BOLD}Press enter to play the first movement.${RESET}")"

    curl -w "\n" -X POST -d "btnStatus=open" https://colmis.robertomochetti.com/admin/form-handler.php & #automatically opens webform
    echo "Playing first movement..."
    pw-play initial-assets/audio-mov1.wav < /dev/null &

    export OLLAMA_HOST=0.0.0.0:11434
    export OLLAMA_CONTEXT_LENGTH=16384
    export OLLAMA_MODELS=/mnt/storage/ollamaModels

    ollama serve > /dev/null 2>&1 &
    OLLAMA_PID=$! # Capture the PID of the last background command
    echo $OLLAMA_PID > /tmp/ollama.pid # Save the PID to a file for later use

    while ! curl -sf http://localhost:11434/api/tags > /dev/null; do
        sleep 0.1
        echo "Waking Ollama up..."
    done
    ollama run $MODEL --hidethinking "say hi" > /dev/null 2>&1 & #warmup ollama as the movement plays for the first time

    sleep 47

    curl -w "\n" -X POST -d "btnStatus=closed" https://colmis.robertomochetti.com/admin/form-handler.php #automatically closes webform
    curl -w "\n" -X POST -d "" https://colmis.robertomochetti.com/admin/merger.php &
}
function play() {
    curl -w "\n" -X POST -d "btnStatus=open" https://colmis.robertomochetti.com/admin/form-handler.php & #automatically opens webform
    echo "Playing..."
    pw-play $1
    #warm ollama up
    export OLLAMA_HOST=0.0.0.0:11434
    export OLLAMA_CONTEXT_LENGTH=16384
    export OLLAMA_MODELS=/mnt/storage/ollamaModels

    ollama serve > /dev/null 2>&1 &
    OLLAMA_PID=$!
    echo $OLLAMA_PID > /tmp/ollama.pid # Overwrite the file with the NEW PID

    while ! curl -sf http://localhost:11434/api/tags > /dev/null; do
        sleep 0.1
        echo "Waking Ollama up..."
    done
    ollama run $MODEL --hidethinking "say hi" > /dev/null 2>&1 & #warmup ollama as the movement plays for the first time
    
    curl -w "\n" -X POST -d "btnStatus=closed" https://colmis.robertomochetti.com/admin/form-handler.php #automatically closes webform
    curl -w "\n" -X POST -d "" https://colmis.robertomochetti.com/admin/merger.php &

    pw-play $1 < /dev/null & #play again but now async while AI prepares the next movement
}

function watchdog() {
    lister="https://colmis.robertomochetti.com/file-lister.php"
    fallback_dir="emergency-stash"
    download_dir="local-inputs" # Make sure this is defined
    
    # Timeout in seconds
    readonly TIMEOUT_SECONDS=15
    
    # Initialize timestamp
    last_file_time=$(date +%s)

    dim_output magick -quiet "$current_bkg" -resize 1920x1080! images/current-image.png

    while true; do
        found_new_file=false
        # ✅ Check the server for a list of files on every loop iteration.
        files=$(curl -s -X POST -d "list" "$lister" | jq -r '.[]')
        
        for f in $files; do
            filename=$(basename "$f")
            if [ ! -f "$download_dir/$filename" ]; then
                echo -e "\nNew file found: $filename. Downloading..."
                
                # ✅ Use --fail (-f) to prevent saving server errors to the file.
                dim_output curl --fail -o "$download_dir/$filename" "https://colmis.robertomochetti.com/downloader.php?file=$filename"
                
                # Check if download was successful AND the file is not empty
                if [ $? -eq 0 ] && [ -s "$download_dir/$filename" ]; then
                    process_file "$download_dir/$filename"
                    found_new_file=true
                    last_file_time=$(date +%s) # Reset timer ONLY on success
                    break # Exit the for loop to process one file at a time
                else
                    echo "Download failed or file was empty. Will retry on the next check."
                    rm -f "$download_dir/$filename" # Clean up the failed/empty file
                fi
            fi
        done

        # If we successfully processed a file, restart the main loop immediately.
        if [ "$found_new_file" = true ]; then
            continue
        fi

        # If no new files were found, check the timeout status.
        current_time=$(date +%s)
        elapsed_time=$((current_time - last_file_time))

        if [ "$elapsed_time" -gt "$TIMEOUT_SECONDS" ]; then
            echo -e "\nTimeout of $TIMEOUT_SECONDS seconds reached. Looking for a fallback file."
            
            # --- Fallback Logic ---
            fallback_triggered=false
            for stash_file in $(find "$fallback_dir" -type f | sort); do
                local filename=$(basename "$stash_file")
                local target_path="$download_dir/$filename"

                if [ ! -f "$target_path" ]; then
                    echo "Using fallback: Copying $filename to $download_dir..."
                    cp "$stash_file" "$target_path"
                    process_file "$target_path"
                    last_file_time=$(date +%s) # Reset timer
                    fallback_triggered=true
                    break
                fi
            done

            # If all fallback files have been used, just reset the timer and keep waiting.
            if [ "$fallback_triggered" = false ]; then
                echo "No unused fallback files found. Resetting timer and continuing to wait."
                last_file_time=$(date +%s)
            fi
        else
            # ✅ If no timeout, show progress and wait just 1 second before re-checking.
            echo -ne "\rLooking for new files... ($((TIMEOUT_SECONDS - elapsed_time))s remaining)   "
            sleep 1
        fi
    done
}
setup
watchdog
