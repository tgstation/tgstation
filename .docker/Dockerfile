FROM ubuntu:18.04

RUN apt-get update && apt-get install -y wget \
	unzip \
	make \
	man \
	vim \
	lib32ncurses5 \
	lib32z1 \
	lib32stdc++6 \
	&& apt-get upgrade -y

RUN mkdir /usr/share/man/man6

RUN wget http://www.byond.com/download/build/512/512.1451_byond_linux.zip

RUN unzip 512.1451_byond_linux.zip -d /tmp/byond
RUN cd /tmp/byond/byond && make install

RUN mkdir /opt/application

COPY ./ /opt/application
RUN cd /opt/application && DreamMaker tgstation.dme

EXPOSE 20000

 
