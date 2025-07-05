<?php
$path = __DIR__ . '/../data/targetTime.txt';
if (!file_exists($path)) {
    echo json_encode(["status" => "missing"]);
    exit;
}

$content = trim(file_get_contents($path));
$target_time = (int)$content;

header('Content-Type: application/json');
echo json_encode([
    "status" => "open",
    "target_time" => (int)$content
]);