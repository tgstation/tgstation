import torch
from TTS.api import TTS
import os
import io
import json
import gc
import random
from flask import Flask, request, send_file, abort
from pydub import AudioSegment
from pydub.silence import split_on_silence

tts = TTS("tts_models/en/vctk/vits", progress_bar=False, gpu=False)
letters_to_use = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
random_factor = 0.35
os.makedirs('samples', exist_ok=True)
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

@app.route("/generate-tts-blips")
def text_to_speech_blips():
	global request_count
	text = request.json.get("text", "").upper()
	voice = request.json.get("voice", "")
	if use_voice_name_mapping:
		voice = voice_name_mapping_reversed[voice]

	result = None
	with io.BytesIO() as data_bytes:
		with torch.no_grad():
			result_sound = None
			if not os.path.exists('samples/' + voice):
				os.makedirs('samples/' + voice, exist_ok=True)
				for i, value in enumerate(letters_to_use):
					tts.tts_to_file(text=value + ".", speaker=voice, file_path="samples/" + voice + "/" + value + ".wav")
					loaded_word = AudioSegment.from_file("samples/" + voice + "/" + value + ".wav")
					audio_chunks = split_on_silence(loaded_word, min_silence_len = 100, silence_thresh = -45, keep_silence = 50)
					combined = AudioSegment.empty()
					for chunk in audio_chunks:
						combined += chunk
					combined.export("samples/" + voice + "/" + value + ".wav", format='wav')
			for i, letter in enumerate(text):
				if not letter.isalpha() or letter.isnumeric() or letter == " ":
					continue
				if letter == ' ':
					new_sound = letter_sound._spawn(b'\x00' * (22050 // 3), overrides={'frame_rate': 22050})
					new_sound = new_sound.set_frame_rate(22050)
				else:
					if not i % 2 == 0:
						continue # Skip every other letter
					if not os.path.isfile("samples/" + voice + "/" + letter + ".wav"):
						continue
					letter_sound = AudioSegment.from_file("samples/" + voice + "/" + letter + ".wav")

					raw = letter_sound.raw_data[2500:-2500]
					octaves = 1 + random.random() * random_factor
					frame_rate = int(letter_sound.frame_rate * (2.0 ** octaves))

					new_sound = letter_sound._spawn(raw, overrides={'frame_rate': frame_rate})
					new_sound = new_sound.set_frame_rate(22050)

				result_sound = new_sound if result_sound is None else result_sound + new_sound
			result_sound.export(data_bytes, format='wav')
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

@app.route("/pitch-available")
def pitch_available():
	abort(500)

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5003, threads=4, backlog=8, connection_limit=24, channel_timeout=10)
