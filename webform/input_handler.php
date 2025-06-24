<?php
// Get status
$btnStatus = $_POST["btnStatus"] ?? null;

if ($btnStatus) {
    $contents = file_get_contents(__DIR__ . '/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }

    if ($btnStatus == "open") {
        $mov++;
        $statusFile = "open | " . htmlentities($mov);
    } elseif ($btnStatus == "closed") {
        $statusFile = "closed | " . htmlentities($mov);
    } elseif ($btnStatus == "reset") {
        $mov = 0;
        $statusFile = "closed | " . htmlentities($mov);
    }

    file_put_contents(__DIR__ . '/formStatus.txt', $statusFile);
    echo $statusFile;
    exit;

} else {
    //reads current movement every time  to properly name the user input file
    $contents = file_get_contents(__DIR__ . '/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }
    // handle audience live descriptions
    $mov_description = $_POST["mov_description"] ?? '';
    if ($mov_description) {
        $inputFile = "<input>\n" . htmlentities($mov_description) . "\n</input>\n";
        file_put_contents(__DIR__ . '/audience-input/input-mov' . $mov . '.txt', $inputFile, FILE_APPEND);
        echo "Description saved.";
    }
}
