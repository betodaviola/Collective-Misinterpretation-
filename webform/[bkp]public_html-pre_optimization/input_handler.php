<?php
// Get status
$btnStatus = $_POST["btnStatus"] ?? null;

if ($btnStatus) {
    $contents = file_get_contents(__DIR__ . '/../data/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }
    if ($btnStatus == "open") {
        if ($matches[1] !== "open") { // only increment if it was closed before
            $mov++;
        }
        $statusFile = "open | " . htmlentities($mov);
        file_put_contents(__DIR__ . '/../data/formStatus.txt', $statusFile);
    } elseif ($btnStatus == "closed") {
        $statusFile = "closed | " . htmlentities($mov);
        file_put_contents(__DIR__ . '/../data/formStatus.txt', $statusFile);
        //handles json download to local computer
        sleep(3); //makes sure every page connected have time to close the form and submit their closing forms
        $database = array_filter(glob(__DIR__ . '/../data/audience-input/*'), 'is_file');
        header('Content-Type: application/json');
        echo json_encode(array_values($database));
    } elseif ($btnStatus == "reset") {
        // updates formStatus.txt accordingly
        $mov = 0;
        $statusFile = "closed | " . htmlentities($mov);
        file_put_contents(__DIR__ . '/../data/formStatus.txt', $statusFile);

        // handles backup of old files there jic:
        $timestamp = date('Ymd-His'); // used at backup directory
        $backup_dir = __DIR__ . '/../data/inputs-bkp' . $timestamp;
        $source_dir = __DIR__ . '/../data/audience-input/';
        sleep(3); //makes sure every page connected have time to close the form and submit their closing forms
        mkdir($backup_dir, 0777, true); // creates backup directory
        foreach (glob($source_dir . '*') as $file) { //foreach iterates through an array. glob() is great: it looks at a directory for a pattern, and makes an array with everything that fits such pattern (directory or file)
            $filename = basename($file); //removes path info
            copy($file, $backup_dir . '/' . $filename);
            unlink($file); //deletes original files
        }
}   
    echo $statusFile;
    exit;
} else {
    //reads current movement every time  to properly name the user input file
    $contents = file_get_contents(__DIR__ . '/../data/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }
    // handle audience live descriptions
    $mov_description = $_POST["mov_description"] ?? '';
    if ($mov_description) {
        $inputFile = "<input>\n" . htmlentities($mov_description) . "\n</input>\n";
        file_put_contents(__DIR__ . '/../data/audience-input/input-mov' . $mov . '.txt', $inputFile, FILE_APPEND);
        echo "Description saved.";
    }
}
