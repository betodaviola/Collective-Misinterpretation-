<?php
    $list = $_POST["list"] ?? null;
    //handles json download information to local watchdog
    $database = array_filter(glob(__DIR__ . '/../data/audience-input/*.txt'), 'is_file');
    header('Content-Type: application/json');
    echo json_encode(array_values($database));





