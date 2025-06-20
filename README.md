Private GitHub repository for our current AI piece.

Refer to the [changelog.md](https://github.com/betodaviola/Collective-Misinterpretation-/blob/main/changelog.md) file to see current changes and details.

Please feel free to edit this repo in any way you see fit, but try to log the changes and leave necessary notes for the team on [changelog.md](https://github.com/betodaviola/Collective-Misinterpretation-/blob/main/changelog.md).

## Important information for running this code and future steps:
- The main dependency is ollama. It is also crucial to set the environmental property for the context window appropriately.I am still testing it but it would depend on the audience size and real life tests where we can calculate the avarage size of each auidience input. This seems overkill but it is really not, since the window size is greatly changing the speed of summarization in my tests, but if we keep it to low in order to get q faster output and better flow of the piece, the summarization results are not satiscaftory and, sometimes, useless. Simply add the line Environment="OLLAMA_CONTEXT_LENGTH=*window size*" under [Service] at /etc/systemd/system/ollama.service.d/override.conf if you are running this on Linux to change the context window size.
- After a lot of testing, the best summarizing parameters for our fake audience inputs are using the mistral:7b model, with a context window of 16384. It summarizes very well, always under 20 seconds (sometimes as low as 12 seconds). Going with a lower context window has not improved the summarizing time at all.
- I have noticed a big "cold start" penalty when I change models on the summarizing script, or when I run a model for the first time that day. It seems like Ollama needs to clear and/or build cache every time you change models, which has been almost doubling the summarizing time. I might actualy try to measure the difference later, but for now the only solution I can think of is to make sure have a "warm-up" run of the script with fake audience inputs minutes before the performance.

