# Docker-Compose Test Server

This is a directory made for easily spinning up a /tg/station server using Docker-Compose.
Also with some tweaks done to read environment variables, like database config and ranks.

# How to use this?

## Prerequisites:
- Docker and `docker-compose` installed
- Text editor
- Basic knowledge about the CLI and containers

## Quickstart:

1) Open a terminal (bash,powershell,cmd,whatever)
2) Clone [the /tg/station repository](https://github.com/tgstation/tgstation) ( CLI: `git clone https://github.com/tgstation/tgstation`)
3) Enter this directory (`cd tgstation/tools/DockerTestServer`)
4) Make a copy of the `example.env` file and call it `.env` (`cp example.env .env`)
5) Edit the values in `.env` (the content and commented out sections, seriously, read it)
6) When all and dandy, start the server by doing `docker-compose up`

After this, you should be able to connect over to your server by opening BYOND and joining your game with an URL that looks like this `byond://localhost:1337` or if you are hosting this on another device `byond://192.168.1.25:1337` or whatever that device's IP or domain is.

## Turning off the server:

Same directory as before in the terminal, try `docker-compose down`

This should turn it off until the next time you turn it on using `docker-compose up`

# Overriding configuration files

Since you might need to tweak `game_options.txt` or any other file in the [/config](/config/) folder. 

This setup allows you to slap those files right into the `./gamecfg` folder for overriding files. Just copy the file you want to override into this directory and the `entrypoint.sh` should apply it during start-up!

Remember to properly take down the container ( `docker-compose down` ) if  you have issues with recent changes not syncronizing after restart.