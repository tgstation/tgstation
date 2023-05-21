import os
import io
import gc
import subprocess
import requests
import re
from flask import Flask, request, send_file, abort

app = Flask(__name__)

authorization_token = os.getenv("TTS_AUTHORIZATION_TOKEN", "coolio")

def hhmmss_to_seconds(string):
	new_time = 0
	separated_times = string.split(":")
	new_time = 60 * 60 * float(separated_times[0])
	new_time += 60 * float(separated_times[1])
	new_time += float(separated_times[2])
	return new_time

def text_to_speech_handler(endpoint, voice, text, filter_complex):
	filter_complex = filter_complex.replace("\"", "")

	response = requests.get(f"http://tts-container:5003/" + endpoint, json={ 'text': text, 'voice': voice })
	if response.status_code != 200:
		abort(500)

	ffmpeg_result = None
	if filter_complex != "":
		ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-filter_complex", filter_complex, "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=response.content, capture_output = True)
	else:
		ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=response.content, capture_output = True)
	ffmpeg_metadata_output = ffmpeg_result.stderr.decode()
	print(f"ffmpeg result size: {len(ffmpeg_result.stdout)} stderr = \n{ffmpeg_metadata_output}")


	matched_length = re.search(r"time=([0-9:\\.]+)", ffmpeg_metadata_output)
	hh_mm_ss = matched_length.group(1)
	length = hhmmss_to_seconds(hh_mm_ss)

	response = send_file(io.BytesIO(ffmpeg_result.stdout), as_attachment=True, download_name='identifier.ogg', mimetype="audio/ogg")
	response.headers['audio-length'] = length
	return response

@app.route("/tts")
def text_to_speech_normal():
	if authorization_token != request.headers.get("Authorization", ""):
		abort(401)

	voice = request.args.get("voice", '')
	text = request.json.get("text", '')

	filter_complex = request.args.get("filter", '')
	return text_to_speech_handler("generate-tts", voice, text, filter_complex)

@app.route("/tts-blips")
def text_to_speech_blips():
	if authorization_token != request.headers.get("Authorization", ""):
		abort(401)

	voice = request.args.get("voice", '')
	text = request.json.get("text", '')

	filter_complex = request.args.get("filter", '')
	return text_to_speech_handler("generate-tts-blips", voice, text, filter_complex)



@app.route("/tts-voices")
def voices_list():
	if authorization_token != request.headers.get("Authorization", ""):
		abort(401)

	response = requests.get(f"http://tts-container:5003/tts-voices")
	return response.content

@app.route("/health-check")
def tts_health_check():
	gc.collect()
	return "OK", 200

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5002, threads=2, backlog=8, connection_limit=24, channel_timeout=10)
