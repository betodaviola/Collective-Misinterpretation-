# Progress Log

## 2025-06-09 (Roberto)
- Initialized GitHub repository
- Uploaded first comparison of models for fake test reviews to fake-reviews/model-comparison.txt
- Created repository scaffolding
- Created readme.md

## 2025-06-10 (Roberto)
- Created a bash script that generates fake reviews so we can simulate an audience to test the patch at fake-reviews/review-generator.sh
- Created a file with a database of reviews that are approximately 1/3 positive, 1/3 negative, and 1/3 neutral. Will create overwhelmingly positive and negative databases for test comparison in the future. The database is at fake-reviews/balanced-reviews.txt

### Notes
- Used shell for this script because I was already running ollama in my terminal and that seemed to make sense now. Can adapt it to python later if necessary.
- In my laptop each review takes about 70 seconds to be generated. That is about 40 minutes to simulate an audience of 30 people, and 1 hour for an audience of 50 people.
- Script allows to change the number of reviews, and the percentage of positive/negative/neutral reviews.
