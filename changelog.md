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

## 2025-06-14 (Roberto)
- Started working on the summarization of the audience inputs by creating a script capable of summarizing the fake reviews by using the Ollama AI models. It can be found at review-summarization/summarizer.sh
- Extracted some summaries and started working on prompting and experimenting with different models for that. Weirdly, deepseek was worse at following the prompt summarization rules than weaker models. This is not all bad, as the summarization needs to happen quicly in between movements. All summaries can be found at review-summarization/ under the name pattern *model used*-sum-*review tone*-reviews.txt
- Improved fake-review/review-generator.sh, and generated the review databases again.
- Added changelog.md link to README.md

### Notes
- Using the word "review" to describe it to the AI proved to be a big mistake so all the scripts and prompts had to be reworked to avoid that word and get more precise AI outputs. Because of that, I decided to redo all of the fake review databases.
- Sometimes, prompted rules are broken by the AI when summarizing too many audience, since the prompt becomes bigger than the context window of the AI. Despite the context being a problem, adding more details to prompt seems to make it better for mistral so I am trying that. A possible hack hack could be to resumarize the first output of the summarize (creating the first output as a temp file). The problem with this hack is that would make using slower and more powerfull models not possible since it would take too long between movements.
- Luckly, mistral:7b is extremelly fast summarizing. I will start testing other models for that and try to use word cloud as a tool to quicly, visualy compare summarizations of the same database.

## 2025-06-16 (Roberto)
- Finally figured out how to make the models follow the rules when summarizing the audience inputs, which is to set the context window environmental variable correctly (details on how to do it on README). I though this was a problem early in the process but messing around with it didn't fix anything because I was using the wrong syntax. 
- Made the PROMPT variable on review-summarization/summarizer.sh access a file called sum-*n*.txt at summarizing-prompts/, where *n*  can be anything that differenciates one prompt from another. This makes easier to edit and polish more than one prompt at the same time and change them in the script: simply modify the variable name on the top of the script.

## 2025-06-19 (Roberto)
- Now that every model is much more competent at summarizing very large amounts of text, I updated our summarizing prompts accordingly, and organized them on directories named after the prompt tested and the context window size.
- Finished summarizing tests and added results to README.md