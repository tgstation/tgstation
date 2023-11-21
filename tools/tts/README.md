## Basic documentation
To run follow these steps:
1. Install [Docker](https://docs.docker.com/get-docker/)
2. Run `docker compose up -d` in the ./tools/tts folder. This may take a while the first time.
3. To build the container after making any changes to the non-persistent files, you can do `docker compose build`

### If you are testing on local
Once it's running, edit your config so that `TTS_HTTP_URL` is set to http://localhost:5002 and `TTS_HTTP_TOKEN` is set to `coolio`

### If you are deploying to prod
Edit your config so that `TTS_HTTP_URL` is a http request to your TTS server (whether that be localhost, an ip address or a domain) on port 5002 and `TTS_HTTP_TOKEN` is set to a random string value. You'll also need to modify the `tts-api.py` file and set the `authorization_token` variable to whatever you've set your `TTS_HTTP_TOKEN` to. This is to prevent unauthorized requests.
