<?php
sleep(5); // Buffer time after form closes

// Fetch movement number
$contents = file_get_contents(__DIR__ . '/../../data/formStatus.txt');
if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
    $mov = (int)$matches[2];
}

$input_dir = __DIR__ . '/../data/audience-input/';
$tmp_files = glob($input_dir . "mov{$mov}-*.tmp");

// Build merged content
$final = '';
foreach ($tmp_files as $f) {
    $final .= file_get_contents($f) . "\n";
    unlink($f); // Delete each after reading
}

// Write to a temp file first
$tmp_output_file = $input_dir . "input-mov{$mov}.finalizing";
$fp = fopen($tmp_output_file, 'w');
fwrite($fp, $final);
fflush($fp);
fclose($fp);

// Atomically rename it to the final .txt name
$final_file = $input_dir . "input-mov{$mov}.txt";
rename($tmp_output_file, $final_file);

// Optional: log
file_put_contents(__DIR__ . '/merge.log', date('c') . " wrote final file for mov $mov\n", FILE_APPEND);
