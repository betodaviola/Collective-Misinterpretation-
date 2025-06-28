<?php
#this is necessary because my index.html does not have the necessary permissions to directly fecth the data/formStatus.txt, so it needs to go through my php server
header("Content-Type: text/plain");
$status_file = __DIR__ . '/../data/formStatus.txt';
if (file_exists($status_file) && is_readable($status_file)) {
    echo file_get_contents($status_file);
} else {
    http_response_code(500);
    echo "Error: status file not accessible.";
}
