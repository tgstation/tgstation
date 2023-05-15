import torch
from TTS.api import TTS
import os
import io
import json
import gc
from flask import Flask, request, send_file

tts = TTS("tts_models/en/vctk/vits", progress_bar=False, gpu=False)

app = Flask(__name__)

voice_name_mapping = {}
use_voice_name_mapping = True
with open("./tts_voices_mapping.json", "r") as file:
    voice_name_mapping = json.load(file)
    if len(voice_name_mapping) == 0:
        use_voice_name_mapping = False

voice_name_mapping_reversed = {v: k for k, v in voice_name_mapping.items()}

request_count = 0

@app.route("/generate-tts")
def text_to_speech():
	global request_count
	text = request.json.get("text", "")
	voice = request.json.get("voice", "")
	if use_voice_name_mapping:
		voice = voice_name_mapping_reversed[voice]

	result = None
	with io.BytesIO() as data_bytes:
		with torch.no_grad():
			tts.tts_to_file(text=text, speaker=voice, file_path=data_bytes)
		result = send_file(io.BytesIO(data_bytes.getvalue()), mimetype="audio/wav")
	request_count += 1
	return result

@app.route("/tts-voices")
def voices_list():
	if use_voice_name_mapping:
		data = list(voice_name_mapping.values())
		data.sort()
		return json.dumps(data)
	else:
		return json.dumps(tts.voices)

@app.route("/health-check")
def tts_health_check():
	gc.collect()
	if request_count > 2048:
		return f"EXPIRED: {request_count}", 500
	return f"OK: {request_count}", 200

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5003, threads=4, backlog=8, connection_limit=24, channel_timeout=10)
