<?php
$mov_description = $_POST["mov_description"] ?? '';
//get movement numbre for file naming
$status_file = file_get_contents(__DIR__ . '/../data/formStatus.txt');
if (preg_match("/(open|closed) \| (\d+)/", $status_file, $matches)) {
    $mov = (int)$matches[2];
}
if ($mov_description) {
    $inputFile = "<input>\n" . $mov_description . "\n</input>\n";
    $uploadDir = realpath(__DIR__ . '/../data/audience-input');  // because tempnam NEEDS the absolute path
    $tempPrefix = 'mov' . $mov . '-';
    $tempFile = tempnam($uploadDir, $tempPrefix);
    // next 2 lines add extension just in case that would be a problem for some hosts and manual navigation
    $renamedFile = $tempFile . '.tmp';
    rename($tempFile, $renamedFile);
    file_put_contents($renamedFile, $inputFile);
}
