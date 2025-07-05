<?php
$filename = basename($_GET['file'] ?? '');
$path = __DIR__ . '/../data/audience-input/' . $filename;

if (!preg_match('/^[a-zA-Z0-9_\-\.]+$/', $filename)) {
    http_response_code(400);
    echo "Invalid filename.";
    exit;
}

if (file_exists($path)) {
    header('Content-Type: text/plain');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    readfile($path);
    exit;
} else {
    http_response_code(404);
    echo "File not found.";
    exit;
}
