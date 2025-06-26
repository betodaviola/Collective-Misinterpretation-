#!/usr/bin/env bash
#Dependencies: jq
url="http://localhost:8000/input_handler.php"
download_dir="/mnt/storage/Stuff/tux_bkp/GitProjects/colectiveMisinterpretation/local-inputs"

# Get JSON listing
files=$(curl -s -X POST -d "btnStatus=closed" "$url" | jq -r '.[]')
for f in $files; do
    filename=$(basename "$f")
    if [ ! -f "$download_dir/$filename" ]; then
        echo "Downloading $filename..."
        curl -o "$download_dir/$filename" "http://localhost:8000/audience-input/$f"

        # Here you can call another script for processing:
        # ./process_file.sh "$download_dir/$filename"
    else
        echo "Already have $filename"
    fi
done
