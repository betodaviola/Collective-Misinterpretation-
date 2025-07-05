Private GitHub repository for our current AI piece.

Refer to the [changelog.md](https://github.com/betodaviola/Collective-Misinterpretation-/blob/main/changelog.md) file to see current changes and details.

Please feel free to edit this repo in any way you see fit, but try to log the changes and leave necessary notes for the team on [changelog.md](https://github.com/betodaviola/Collective-Misinterpretation-/blob/main/changelog.md).

The performance will be run thorugh the [admin page] (https://colmis.robertomochetti.com/admin/) and the main local script collectiveMisinterpretation.sh

The will need to acces [this form]. (https://colmis.robertomochetti.com/).



Dependencies: ollama (mistral:7b), jq.

## Important information for running this code and future steps:
- The window size environmental variable in Ollama might need to change according to the size of the audience. In Linuix, simply add the line Environment="OLLAMA_CONTEXT_LENGTH=*window size*" under [Service] at /etc/systemd/system/ollama.service.d/override.conf. After some texting, a context window of 16384 seems ideal.