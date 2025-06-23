<?php
  $mov_description = $_POST["mov_description"]?? '';//question marks and quotation at the end means to return an empty string if nothing is there to submit

if (!$mov_description) {
    echo "No review received.";
    exit;
}

// Append to descriptions file
$input = "<input>\n" . htmlentities($mov_description) . "\n</input>\n";
file_put_contents(__DIR__ . '/input-tests/audience_input.txt', $input, FILE_APPEND);

?>