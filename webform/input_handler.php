<?php
  ////handle admin page buttons and formStatus.txt
  $btnStatus = $_POST["btnStatus"] ?? null;
  if ($btnStatus == "open") {
    //The next 3 lines use clever ReGex and syntax to read the value referent to the movementy number inside the file and save as the third element in an array (matches[2])
    // I was stuck on this step and asked a LLM for help, so I am not sure exactly how the ReGex line works but it does.
    $contents = file_get_contents(__DIR__ . '/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }
    $mov++;
    $statusFile = "open | " . htmlentities($mov);
    file_put_contents(__DIR__ . '/formStatus.txt', $statusFile);
  } elseif ($btnStatus == "closed") {
    //read previous comment.
    $contents = file_get_contents(__DIR__ . '/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
        $mov = (int)$matches[2];
    }
    $statusFile = "closed | " . htmlentities($mov);
    file_put_contents(__DIR__ . '/formStatus.txt', $statusFile);
  } elseif ($btnStatus == "reset") {
    $mov = 0;
    $statusFile = "closed | " . htmlentities($mov);
    file_put_contents(__DIR__ . '/formStatus.txt', $statusFile);
 }
  //returs the line to the html to make sure it works. can also be used to update the status
  echo $statusFile;




  //creates audience_input.txt
  $mov_description = $_POST["mov_description"] ?? '';//question marks and quotation at the end means to return an empty string if nothing is there to submit

  // Append to descriptions file
  $inputFile = "<input>\n" . htmlentities($mov_description) . "\n</input>\n";
  file_put_contents(__DIR__ . '/input-tests/audience_input.txt', $inputFile, FILE_APPEND); 

?>