#!/usr/bin/env bash
#Dependencies: jq, ollama, stable-audio-tools, wordcloud

###SET ACCORDING TO THE HALL
ADMIN_WKSP="workspace 11" # home: "workspace 11" | performance hall: ADMIN_WKSP="workspace 1"
AUDIENCE_WKSPC="workspace 2" # home: "workspace 2" | performance hall: ADMIN_WKSP="workspace 11"

download_dir="local-inputs"
MODEL="mistral:7b"

current_bkg=bkg-mov1.png #You need a first image already done to make it run smoothly


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


function setup() {
    dim_output i3-msg "$AUDIENCE_WKSPC"
    cp qr-code.png images/current-image.png
    sleep 0.4
    pqiv --fullscreen --hide-info-box --fade --scale-images-up --watch-files=on --fade-duration=1 images/current-image.png &
    while ! xdotool search --class pqiv >/dev/null 2>&1; do sleep 0.1; done #this should wait until image opens so it does not steal focus. If does not work uncomment and maybe adjust sleep line below
    sleep 0.4 # still needs time or it will transfer the background to your current workspace
    dim_output i3-msg "$ADMIN_WKSP"
    
    echo -e "${BOLD}Instructions:${RESET}"
    echo -e "1. Make sure to open the admin webpage for the project and click the ${UND}RESET${RESET} button."
    echo -e "2. Backup all local data from previous performances. It is recommended to clean the folders when asked on this prompt"
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
                    echo "The contents of $download_dir/  and summaries/ have been deleted. Proceeding."
                    ##ADD THE OPTION TO CLEAN OTHER FOLDERS RELATED TO THE AI PARTS OF THE PROCESS LATER
                fi
                break;;
            No ) 
                echo -e "${BOLD}${RED}WARNING:${RESET}${BOLD} The piece will NOT run properly if folders are not clean. If this is not a test, please backup necessary local files, restart this script, and choose to clean local directories.${RESET}"
                break;;
        esac
    done

    sleep 0.5
    echo -e "If you already ${UND}RESET${RESET} the form through the admin page, the performance can start."
    read -p "$(echo -e "${BOLD}Press enter to play the first movement.${RESET}")"
}
function play() {
    echo "Playing..."
    pw-play $1
    #warm ollama up while playing
    export OLLAMA_HOST=0.0.0.0:11434
    export OLLAMA_CONTEXT_LENGTH=16384
    export OLLAMA_MODELS=/mnt/storage/ollamaModels
    ollama serve > /dev/null 2>&1 &
    while ! curl -sf http://localhost:11434/api/tags > /dev/null; do
        sleep 0.1
        echo "Waking Ollama up..."
    done
    ollama run $MODEL --hidethinking "say hi" > /dev/null 2>&1 & #warmup ollama as the movement plays for the first time
    pw-play $1 & #play again but now async while AI prepares the next movement
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
                dim_output curl -o "$download_dir/$filename" "https://colmis.robertomochetti.com/downloader.php?file=$filename"
                found_new_file=true
                #summarization process start
                sum_start=$(date +%s)

                input_n=$(grep "<input>" $download_dir/$filename | wc -l)
                echo -e "${UND}Summarizing${RESET} audience input from $download_dir/$filename. Total inputs to summarize: ${UND}$input_n${RESET}"

                ( #wrapped in a subshell to be full async
                    dim_output wordcloud_cli --text $download_dir/$filename --stopwords stop-words.txt --width 1800 --height 980 --mode RGBA --color "#ff0000" --background "#00000040" --imagefile images/cloud.png
                    dim_output magick convert \
                        $current_bkg -resize 1920x1080! \
                        null: images/cloud.png -gravity center -layers composite \
                        images/current-image.png &
                ) &

                # Delete contents of output file if it exists, or creates it if it doesn't
                output="summaries/sum-${filename#input-}"
                : > "$output" 

                REVIEWS=$(cat "$download_dir/$filename")
                PROMPT_SUM=$(cat "summary-prompt.txt")
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

                #SUmmarizes user inputs
                ollama run $MODEL --hidethinking "$PROMPT" >> "$output"

                sum_end=$(date +%s)
                sum_dur=$((sum_end - sum_start))
                echo -e "Done. ${UND}$input_n${RESET} reviews were summarized in ${UND}${sum_dur}s${RESET}, and saved to $output."

                sleep 0.5
                killall ollama #Need to make sure EVERYTHING in the gpu is available

                #starting generative proccess for the next movement
                gen_start=$(date +%s)
                
                source ~/stable-audio-tools/.venv/bin/activate #needs an outdated version of python to run

                #wrapped in a subshell to be full async
                bkg_path_file=$(mktemp)
                (
                    python image-gen.py "$output" | tail -n 1 | tr -d '\r\n' > "$bkg_path_file"
                ) &

 #               current_bkg=$(python image-gen.py "$output" | tail -n 1 | tr -d '\r\n') &
                

                dim_output huggingface-cli login --token "$(cat tk.txt)" #you also need to login into the hugginface account
                new_mov=$(PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python audio-gen.py "$output"| tail -n 1 | tr -d '\r\n') #tail and tr makes sure it ignores all outputs from the script except the last print() when assigning it to the variable
                deactivate #gets out from outdated python environment

                gen_end=$(date +%s)
                gen_dur=$((gen_end - gen_start))
                gen_total=$((gen_end - sum_start))
                echo -e "Done. ${new_mov} was created in ${UND}${sum_dur}s${RESET}. ${UND}${gen_total}s${RESET} after audience input was downloaded."
                sleep 0.5
                
                read -p "$(echo -e "${BOLD}Press enter to play the next movement.${RESET}")"

                word_n=$(cat "$output" | wc -w)

                # Wait for background image generation to complete
                while [[ ! -s "$bkg_path_file" ]]; do
                    sleep 0.1
                done
                current_bkg=$(< "$bkg_path_file")

                cp $current_bkg images/current-image.png


                if (( word_n > 160 )); then
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
                            dim_output magick \
                                \( "$current_bkg" -resize 1920x1080! \) \
                                \( -size 1800x1000 -gravity center -background 'rgba(0,0,0,0.4)' -fill white -font Adwaita-Sans-Bold -pointsize 45 caption:"$part" \) \
                                -gravity center -composite \
                                images/current-image.png

                            sleep 20
                        done
                        dim_output cp $current_bkg images/current-image.png

                        dim_output rm "$split_file1" "$split_file2"
                    ) &

                else
                    display_prompt="\"$(cat $output)\""
                    dim_output magick \
                        \( "$current_bkg" -resize 1920x1080! \) \
                        \( -size 1800x1000 -gravity center -background 'rgba(0,0,0,0.4)' -fill white -font Adwaita-Sans-Bold -pointsize 45 caption:"$display_prompt" \) \
                        -gravity center -composite \
                        images/current-image.png
                fi
                
                play $new_mov
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
play audio-mov1.wav
watchdog
