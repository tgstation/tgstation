FROM ghcr.io/coqui-ai/tts-cpu:a31af762e8ad4d8551c67b7f15e80fad1a21ebd2
# install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg
RUN pip install Flask
RUN pip install ffmpeg-python
RUN pip install waitress
COPY . /root
RUN mkdir /tts_files
WORKDIR /root

ENTRYPOINT [ "python3", "tts-api.py" ]
