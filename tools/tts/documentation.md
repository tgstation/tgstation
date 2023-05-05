## Basic documentation
To run, simply do `docker compose up -d` in the tts and ffmpeg folders.
This will build the container if it isn't build already, but if it is, then it'll re-use the built image.

To build the container after making any changes to the non-persistent files, you can do `docker compose build`
