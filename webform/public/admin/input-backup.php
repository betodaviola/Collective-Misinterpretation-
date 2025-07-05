<?php
// handles backup of old files there jic:
$source_dir = __DIR__ . '/../../data/audience-input/';
if (count(glob($source_dir . "*")) === 0) { //runs backup only if there are files to backup
    echo "No input files to backup. Ready to start the piece.";
} else {
    $timestamp = date('Ymd-His'); // used at backup directory
    $backup_dir = __DIR__ . '/../../data/inputs-bkp' . $timestamp;
    sleep(3); //makes sure every page connected have time to close the form and submit their closing forms
    mkdir($backup_dir, 0777, true); // creates backup directory
    foreach (glob($source_dir . '*') as $file) { //foreach iterates through an array. glob() is great: it looks at a directory for a pattern, and makes an array with everything that fits such pattern (directory or file)
        $filename = basename($file); //removes path info
        copy($file, $backup_dir . '/' . $filename);
        unlink($file); //deletes original files
    }
    echo "Backup done and input folder clean. Ready to start the piece.";
}