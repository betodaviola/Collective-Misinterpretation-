#!/bin/bash
# You need to run this every time you come to work on your linux computer after doing work on the windows computer.
# Ironically, chmod +x will also have to be run on this script. Might try to automatize and run when docker container starts later
chmod +x watchdog-test.sh fake-reviews/review-generator.sh review-summarization/summarizer.sh collectiveMisinterpretation.sh
chmod -R g+rw webform/data
chmod -R 777 webform/data
