#!/usr/bin/env bash
#Dependencies: jq
url="http://localhost:8000/input_handler.php"
download_dir="local-inputs"

function watchdog() {
    echo "Waiting for new input files..."

    while true; do
        # Get JSON listing
        files=$(curl -s -X POST -d "btnStatus=closed" "$url" | jq -r '.[]') ###THIS LINE IS DIFFERENT IN WIN
        for f in $files; do
            filename=$(basename "$f")
            if [ ! -f "$download_dir/$filename" ]; then
                echo "Downloading $filename..."
                curl -o "$download_dir/$filename" "http://localhost:8000/data/audience-input/$filename"

                break
                # Here you can call another script for processing:
                # ./process_file.sh "$download_dir/$filename"
            else
                echo "No new files available"
                sleep 1
            fi
        done
    done
}

watchdog
echo "DONE"

