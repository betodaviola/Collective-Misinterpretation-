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

## 2025-06-11 (Roberto)
- Moved the prompt used on the fake review script to its own file to make editing it easier. It is now at fake-review/review-prompt.txt.
- Refined the fake review prompt and the script.
- Created three databases simulating audience inputs. One with the reviews overwhelmingly positive, one with reviews overwhelmingly negative, and one balanced (substituting the balanced database created yesterday, since the prompt was improved). They all can be found at fake-reviews/

### Notes
- I am really unhappy with how the script calculates the percentages, since bash does not deal with floating points without some extra work put into it. I don't think this is a big deal for what we need this script, but if we decide that we need precision later on, it might be worth it rewriting the whole thing in python, or deal with actual review numbers rather than percentages.