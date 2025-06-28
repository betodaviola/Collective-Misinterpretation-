#!/usr/bin/env bash
#Dependencies: jq

###IMPORTAANT EXTRA LINE TO RUN THIS ON WINDOWS 
jq="win64-depedencies/jq-win64.exe"  # very interesting way to deal with linux packages on windows. jq for example had the binary .exe available so you can just create an alias of sort to execute it. JUST MAKE SURE TO CHANGE THE packagename TO "$packagename" on the code so its more of a variable than a package being executed

url="http://localhost:8000/input_handler.php"
download_dir="local-inputs"

# Get JSON listing
files=$(curl -s -X POST -d "btnStatus=closed" "$url" | "$jq" -r '.[]')
for f in $files; do
    filename=$(basename "$f")
    if [ ! -f "$download_dir/$filename" ]; then
        echo "Downloading $filename..."
        curl -o "$download_dir/$filename" "http://localhost:8000/data/audience-input/$filename"

        # Here you can call another script for processing:
        # ./process_file.sh "$download_dir/$filename"
    else
        echo "Already have $filename"
    fi
done

