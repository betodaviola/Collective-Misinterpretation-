#!/usr/bin/env bash
#Dependencies: jq
url="http://localhost:8000/file-lister.php"
download_dir="local-inputs"

function watchdog() {
    while true; do
        echo -n "$search_status"
        # Get JSON listing
        files=$(curl -s -X POST -d "list" "$url" | jq -r '.[]') ###THIS LINE IS DIFFERENT IN WIN
        for f in $files; do
            filename=$(basename "$f")
            if [ ! -f "$download_dir/$filename" ]; then
                echo "Downloading $filename..."
                curl -o "$download_dir/$filename" "http://localhost:8000/data/audience-input/$filename"
                break
            else
                dots=("." ".." "...")
                for d in "${dots[@]}"; do
                    echo -ne "\rLooking for new files$d   "
                    sleep 1
                done
            fi
        done
    done
}

watchdog
echo "DONE"

