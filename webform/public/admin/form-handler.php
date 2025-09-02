<?php
  // Get status
  $btnStatus = $_POST["btnStatus"] ?? null;
  if ($btnStatus) {
    $contents = file_get_contents(__DIR__ . '/../../data/formStatus.txt');
    if (preg_match("/(open|closed) \| (\d+)/", $contents, $matches)) {
      $mov = (int)$matches[2];
    }
    if ($btnStatus == "open") {
      if ($matches[1] !== "open") { // only run this block number if it was closed before
        // sets target time for forms to close
        $target_time = time() + 47;
        file_put_contents(__DIR__ . '/../../data/targetTime.txt', $target_time);
        //edits the formStatus file
        $mov++;
        $statusFile = "open | " . htmlentities($mov);
        file_put_contents(__DIR__ . '/../../data/formStatus.txt', $statusFile);
        echo $statusFile; // return only the status
      }
    } elseif ($btnStatus == "closed") {
      if ($matches[1] !== "closed") { // only run this block number if it was open before
        $statusFile = "closed | " . htmlentities($mov);
        file_put_contents(__DIR__ . '/../../data/formStatus.txt', $statusFile);
        echo $statusFile; // return only the status
      }
    } elseif ($btnStatus == "reset") {
      // updates formStatus.txt accordingly
      $mov = 0;
      $statusFile = "closed | " . htmlentities($mov);
      file_put_contents(__DIR__ . '/../../data/formStatus.txt', $statusFile);
      echo $statusFile; // return only the status
    } elseif ($btnStatus == "check") {
      echo $contents;
    }
    exit;             // prevent the rest of the page from being sent
  }