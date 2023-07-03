# Grab debian-bullseye-slim
FROM debian:bullseye-slim

# install required packages
RUN apt-get update && apt-get upgrade && apt-get install -y wget curl espeak-ng &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Anaconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py310_22.11.1-1-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Enable intel packages
RUN conda config --add channels intel
# Setup intel enhanced python environment named 'intel'.
RUN conda create -n intel intelpython3_full python=3.9 numba=0.55.1 && conda clean --index-cache --tarballs --packages
# Use the intel enhanced python environment from now on.
SHELL ["conda", "run", "-n", "intel", "/bin/bash", "-c"]

# Setup python requirements and install the TTS python module into the new intel anaconda environment.
RUN pip install Flask &&\
	pip install waitress &&\
	pip install llvmlite --ignore-installed &&\
	pip install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118 &&\
	pip install pydub &&\
	pip install TTS &&\
	pip cache purge

COPY . /root
RUN mkdir /tts_data
WORKDIR /root


# fix: `libstdc++.so.6: version `GLIBCXX_3.4.29' not found`
# tl;dr is we need to have /opt/conda/lib in the library path for python, but *not things ran by python*
# the python script will look for TTS_LD_LIBRARY_PATH and use it for things it runs.
RUN conda env config vars set TTS_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
RUN conda env config vars set LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_DIR/lib

ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "intel", "python", "tts.py"]
