#!/usr/bin/env bash
#Dependencies: jq
url="http://localhost:8000/file-lister.php"
download_dir="local-inputs"

function setup() {
    #This is a cool method for simple questions. Differently from using read -p, you don't need to sanitize it
    echo "Do you wanna clean the local directories? (1 or 2) Please backup important data first."
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                if [ -z "$( ls $download_dir )" ]; then #-z checks if the length of a string is 0 (if string is either empty or null)
                    echo "$download_dir is empty. Proceeding."
                else
                    rm $download_dir/*
                    echo "The contends of $download_dir have been deleted. Proceeding."
                    ##ADD THE OPTION TO CLEAN OTHER FOLDERS RELATED TO THE AI PARTS OF THE PROCESS LATER
                fi
                break;;
            No ) 
                echo "The piece will NOT run properly if folders are not clean. If this is not a test, please backup necessary local files, restart this script, and choose to clean local directories."
                break;;
        esac
    done


    ##ADD WARMING UP SESSION FOR THE OLLAMA ENGINE
}

function watchdog() {
    while true; do
        found_new_file=false
        files=$(curl -s -X POST -d "list" "$url" | jq -r '.[]')
        for f in $files; do
            filename=$(basename "$f")
            if [ ! -f "$download_dir/$filename" ]; then
                echo "Downloading $filename..."
                curl -o "$download_dir/$filename" "http://localhost:8000/data/audience-input/$filename"
                found_new_file=true
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

