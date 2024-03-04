import torch
from TTS.api import TTS
import os
import io
import json
import gc
import random
import numpy as np
import ffmpeg
from typing import *
from modules import models
from modules.utils import load_audio
from flask import Flask, request, send_file, abort, make_response
from pydub import AudioSegment
from pydub.silence import split_on_silence, detect_leading_silence
from fairseq import checkpoint_utils
from fairseq.models.hubert.hubert import HubertModel
from modules.shared import ROOT_DIR, device, is_half
import requests
import librosa

### READ ME
# How to use this version after doing normal TTS setup.
# 1. Clone https://github.com/ddPn08/rvc-webui.git somewhere, and pip install the ./requirements/main.txt requirements file.
# 2. This will downgrade Librosa, which doesn't matter, TTS still runs properly, ignore it.
# 3. Put this .py file and the two .wav files next to it in the base of the rvc-webui repository you cloned.
# 4. Place your .pth files and .json files in the ./models/checkpoints folder in the cloned repository.
# 5. Download hubert_base.pt from https://huggingface.co/lj1995/VoiceConversionWebUI/tree/main and place it in the ./models/embeddings folder in the cloned repository.
# 6. Boot this instead of tts.py.
# "What does this actually do?"
# This puts the Retrieval-Voice-Conversion model between the TTS and the actual webserver, allowing for improved speaker accuracy and improved audio quality.
### READ ME
# UPDATE ME FOR YOUR OWN MODEL FILES YOU TRAIN
vc_models = {
	"TGStation_Crepe_1.pth": "./models/checkpoints/speakers_tgstation_1.json",
	"TGStation_Crepe_2.pth": "./models/checkpoints/speakers_tgstation_2.json",
	"TGStation_Crepe_3.pth": "./models/checkpoints/speakers_tgstation_3.json",
}

app = Flask(__name__)

tts = TTS(model_path = "E:/model_output_3/model_no_disc.pth", config_path = "E:/model_output_2/config.json", progress_bar=False, gpu=True)
letters_to_use = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
random_factor = 0.35
os.makedirs('samples', exist_ok=True)
trim_leading_silence = lambda x: x[detect_leading_silence(x) :]
trim_trailing_silence = lambda x: trim_leading_silence(x.reverse()).reverse()
strip_silence = lambda x: trim_trailing_silence(trim_leading_silence(x))
def load_embedder():
    global embedder_model, loaded_embedder_model
    emb_file = "./models/embeddings/hubert_base.pt"
    models, _, _ = checkpoint_utils.load_model_ensemble_and_task(
        [emb_file],
        suffix="",
    )
    embedder_model = models[0]
    embedder_model = embedder_model.to(device)

    if is_half:
        embedder_model = embedder_model.half()
    else:
        embedder_model = embedder_model.float()
    embedder_model.eval()

    loaded_embedder_model = "hubert_base"
    return embedder_model


loaded_models = []
embedder_model: Optional[HubertModel] = load_embedder()
voice_lookup = {}
for model in vc_models.keys():
	print(model)
	voice_lookup[model] = json.load(open(vc_models[model], "r"))
	vc_model = models.get_vc_model(model)
	loaded_models.append(vc_model)
	print("Loaded model " + str(model))
#vc_model = models.get_vc_model(model_path)
embedding_output_layer = 12

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
	pitch_adjustment = request.json.get("pitch", "")
	if use_voice_name_mapping:
		voice = voice_name_mapping_reversed[voice]

	result = None
	with io.BytesIO() as data_bytes:
		with torch.no_grad():
			tts.tts_to_file(text=text, speaker=voice, file_path=data_bytes)
			speaker_id = "NO SPEAKER"
			model_to_use = None
			found_model = False
			for model in voice_lookup.keys():
				speaker_list = voice_lookup[model]
				for speaker in speaker_list.keys():
					if voice == speaker:
						speaker_id = speaker_list[speaker]
						found_model = True
						break
				if found_model:
					model_to_use = loaded_models[list(voice_lookup.keys()).index(model)]
					break
			if speaker_id == "NO SPEAKER" or model_to_use == None:
				abort(500)
			audio, _ = librosa.load(io.BytesIO(data_bytes.getvalue()), sr=16000)

			audio_opt = model_to_use.vc(
				embedder_model,
				embedding_output_layer,
				model_to_use.net_g,
				speaker_id,
				audio,
				int(pitch_adjustment),
				"crepe",
				"",
				0,
				model_to_use.state_dict.get("f0", 1),
				f0_file=None,
			)
			audio = AudioSegment(
				audio_opt,
				frame_rate=model_to_use.tgt_sr,
				sample_width=2,
				channels=1,
			)
			audio.export(
				data_bytes,
				format="wav",
			)
			result = send_file(io.BytesIO(data_bytes.getvalue()), mimetype="audio/wav")
	request_count += 1
	return result

@app.route("/generate-tts-blips")
def text_to_speech_blips():
	global request_count
	text = request.json.get("text", "").upper()
	voice = request.json.get("voice", "")
	pitch_adjustment = request.json.get("pitch", "")
	if use_voice_name_mapping:
		voice = voice_name_mapping_reversed[voice]

	result = None
	with io.BytesIO() as data_bytes:
		with torch.no_grad():
			result_sound = AudioSegment.empty()
			if not os.path.exists('samples/' + voice):
				os.makedirs('samples/' + voice, exist_ok=True)
				for i, value in enumerate(letters_to_use):
					tts.tts_to_file(text=value + ".", speaker=voice, file_path="samples/" + voice + "/" + value + ".wav")
					sound = AudioSegment.from_file("samples/" + voice + "/" + value + ".wav", format="wav")
					silenced_word = strip_silence(sound)
					silenced_word.export("samples/" + voice + "/" + value + ".wav", format='wav')
			speaker_id = "NO SPEAKER"
			model_to_use = None
			found_model = False
			for model in voice_lookup.keys():
				speaker_list = voice_lookup[model]
				for speaker in speaker_list.keys():
					if voice == speaker:
						speaker_id = speaker_list[speaker]
						found_model = True
						break
				if found_model:
					model_to_use = loaded_models[list(voice_lookup.keys()).index(model)]
					break
			if speaker_id == "NO SPEAKER" or model_to_use == None:
				abort(500)
			for i, letter in enumerate(text):
				if not letter.isalpha() or letter.isnumeric() or letter == " ":
					continue
				if letter == ' ':
					new_sound = letter_sound._spawn(b'\x00' * (40000 // 3), overrides={'frame_rate': 40000})
					new_sound = new_sound.set_frame_rate(40000)
					result_sound += new_sound
				else:
					if not i % 2 == 0:
						continue # Skip every other letter
					if not os.path.isfile("samples/" + voice + "/" + letter + ".wav"):
						continue
					if not os.path.isdir("samples/" + voice + "/pitch_" + pitch_adjustment):
						os.mkdir("samples/" + voice + "/pitch_" + pitch_adjustment)
					if not os.path.isfile("samples/" + voice + "/pitch_" + pitch_adjustment + "/" + letter + ".wav"):
						audio, _ = librosa.load("samples/" + voice + "/" + letter + ".wav", 16000)

						audio_opt = model_to_use.vc(
							embedder_model,
							embedding_output_layer,
							model_to_use.net_g,
							speaker_id,
							audio,
							int(pitch_adjustment),
							"crepe",
							"",
							0,
							model_to_use.state_dict.get("f0", 1),
							f0_file=None,
						)
						output_sound = AudioSegment(
							audio_opt,
							frame_rate=model_to_use.tgt_sr,
							sample_width=2,
							channels=1,
						)
						output_sound.export("samples/" + voice + "/pitch_" + pitch_adjustment + "/" + letter + ".wav", format="wav")
					letter_sound = AudioSegment.from_file("samples/" + voice + "/pitch_" + pitch_adjustment + "/" + letter + ".wav")

					raw = letter_sound.raw_data[5000:-5000]
					octaves = 1 + random.random() * random_factor
					frame_rate = int(letter_sound.frame_rate * (2.0 ** octaves))

					new_sound = letter_sound._spawn(raw, overrides={'frame_rate': frame_rate})
					new_sound = new_sound.set_frame_rate(40000)
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
	return make_response("Pitch available", 200)

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5003, threads=4, backlog=8, connection_limit=24, channel_timeout=10)
