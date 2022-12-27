FROM ghcr.io/coqui-ai/tts-cpu
# install ffmpeg
RUN apt-get update && apt-get install -y ffmpeg
RUN pip install Flask
RUN pip install ffmpeg-python
RUN pip install waitress
COPY . /root
RUN mkdir /tts_files
WORKDIR /root

ENTRYPOINT [ "python3", "tts-api.py" ]
