# Collective Misinterpretation - colMis (2025)

Collective Misinterpretation is an interactive AI-driven performance system that turns human misunderstanding and machine error into an audio-visual experience. Through a live feedback loop involving performer, audience, and AI, the piece explores how language, perception, and algorithmic misinterpretation can recursively shape one another in real time. Each performance is the unique result of the conflict between intention and misunderstood output, blurring the boundaries between composer, audience, and machine agency.

Academic writing for conferences and some conceptual framing were developed collaboratively with my colleague and co-creator Carlos Román, who also composed the one-minute fixed media used in the opening movement. All viola writing, system architecture, piece timeline, real-time optimizations, text and audiovisual pipelines, and all computer code were designed and implemented by me (Roberto Mochetti), along with the live improvised and performed materials.

## About the Piece

Collective Misinterpretation treats the tension between human meaning-making and artificial “understanding” not as a technological limitation but as its central creative material. In this work, the audience is invited to become co-authors: during each performance cycle, they describe what they hear using a custom web interface. Their collective responses are summarized by a large language model into a single prompt, which is then used to generate the next movement through a text-to-audio AI system.

This process creates an iterative, recursively evolving structure in which each layer of musical output is shaped by the previous one’s misunderstandings. The system reframes AI not as a tool for realizing a composer’s fixed intentions, but as an unpredictable collaborator whose errors become expressive forces. Across cycles, authorship becomes distributed between the performer who initiates and constantly interprets the musical material, the audience whose interpretations guide the narrative, and the AI whose own misreadings and “interpretation” help pull the piece into unexpected directions.

## Performances

Collective Misinterpretation has been presented at three venues in 2025, including two major international conferences in music, technology, and artificial intelligence:

- Ubiquitous Music Symposium (UbiMus) – Brandenburg, Germany  
- AI Music Creativity Conference (AIMC) – Brussels, Belgium  
- LSU Digital Media Center Theater – premiere performance  

For each performance, the audience’s live descriptions produced fundamentally different musical outcomes, demonstrating the system’s sensitivity to context, interpretation, and cultural framing. The video attached above is a compilation of moments from these three presentations.

## How the code works

Each performance begins with a short movement for viola and fixed media. The whole process is organized by a very long bash script. As the movement unfolds, the following process takes place:

1. Audience members submit real-time textual interpretations through a custom phone-based interface, accessible through a QR code. [This is the (deactivated) page](https://colmis.robertomochetti.com/), for reference.
2. A large language model condenses all audience submissions into a single prompt. For that, I used [the 7B mistral model](https://ollama.com/library/mistral) available through Ollama.
3. This summary is sent to both a text-to-sound ([Stable Audio Open](https://stability.ai/news/introducing-stable-audio-open)) and a text-to-image AI model ([Stable Diffusion v1-4](https://huggingface.co/CompVis/stable-diffusion-v1-4)), both running locally, generating a new musical movement and an accompanying imagine ([pqiv](https://github.com/phillipberndt/pqiv) and [ImageMagick](https://wiki.archlinux.org/title/ImageMagick)) that is projected as a background for the audience’s summarized responses and a live word cloud representing it.
4. The AI-generated movement becomes the starting point for the next cycle, as it is played back for the audience.
5. The audience then interprets this newly generated movement, producing the next prompt and restarting the cycle.

The musical form emerges from the frictions between these human and machine interpretations, unfolding from the pre-established recursive feedback structure.
