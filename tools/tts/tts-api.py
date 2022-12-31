from flask import Flask, request, send_file
import shlex
import os, shutil
import json
import math
import gc
import io
import subprocess
import torch
from torch import nn
from torch.nn import functional as F
from torch.utils.data import DataLoader

import commons
import utils
from data_utils import TextAudioLoader, TextAudioCollate, TextAudioSpeakerLoader, TextAudioSpeakerCollate
from models import SynthesizerTrn
from text.symbols import symbols
from text import text_to_sequence
from text.cleaners import english_cleaners2
from text.symbols import symbols

from scipy.io.wavfile import write

app = Flask(__name__)
vits_model_name = "./pth/vits.pth" # TODO: path to the model
def get_text(text, hps):
    text_norm = text_to_sequence(text, hps.data.text_cleaners)
    if hps.data.add_blank:
        text_norm = commons.intersperse(text_norm, 0)
    text_norm = torch.LongTensor(text_norm)
    return text_norm

hps = utils.get_hparams_from_file("./configs/spanish_li44.json") # TODO: change this to new speaker config when we're ready with a new model

net_g = SynthesizerTrn(
    len(symbols),
    hps.data.filter_length // 2 + 1,
    hps.train.segment_size // hps.data.hop_length,
    **hps.model) #TODO: update for multispeaker
_ = net_g.eval()

_ = utils.load_checkpoint(vits_model_name, net_g, None)

def do_inference_orig(in_txt):
  print(in_txt)
  print(english_cleaners2(in_txt))
  stn_tst = get_text(in_txt, hps)
  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])

    audio = net_g.infer(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1)
    #audio = audio[0][0,0].data.float().numpy()
    attn = audio[0].data.float().numpy()
    print(attn.shape)
    print(attn)
    audio = audio[0].squeeze().data.float().numpy()
    print(len(audio))

  return audio

def do_inference(in_txt,in_vv):
  print(in_txt)
  stn_tst = get_text(in_txt, hps)
  #print(english_cleaners2(in_txt))
  #print(stn_tst)
  len_s = make_var_durp(stn_tst,in_vv)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])
    len_s = len_s.unsqueeze(0)

    audio, attn = net_g.infer_ts(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1.0)
    attn = attn.squeeze().data.float().numpy()
    print(attn.shape)
    audio = audio.squeeze().data.float().numpy()
    print(len(audio))

  return audio

def do_inference_gx(in_txt):
  print(in_txt)
  stn_tst = get_text(in_txt, hps)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])
    audio = net_gx(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1)
    audio = audio.numpy()

  return audio

def do_inference_clean(in_txt):
  stn_tst = get_text(in_txt, hps)

  with torch.no_grad():
    x_tst = stn_tst.unsqueeze(0)
    x_tst_lengths = torch.LongTensor([stn_tst.size(0)])

    audio, attn = net_g.infer_ts(x_tst, x_tst_lengths, noise_scale=.667, noise_scale_w=0.8, length_scale=1.0)
    attn = attn.squeeze().data.float().numpy()
    audio = audio.squeeze().data.float().numpy()

  return audio

request_count = 0

@app.route("/tts")
def text_to_speech():
	global request_count
	request_count += 1

	voice = request.args.get("voice", '')
	text = request.json.get("text", '')

	filter_complex = request.args.get("filter", '')
	filter_complex = filter_complex.replace("\"", "")

	result = None
	with io.BytesIO() as wav_bytes:
		audio = do_inference_clean(text) # TODO: implement voice
		write(wav_bytes, hps.data.sampling_rate, audio)

		ffmpeg_result = None
		if filter_complex != "":
			ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-filter_complex", filter_complex, "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=wav_bytes.getvalue(), capture_output = True)
		else:
			ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=wav_bytes.getvalue(), capture_output = True)
		print(f"ffmpeg result size: {len(ffmpeg_result.stdout)} stderr = \n{ffmpeg_result.stderr.decode()}")

		result = send_file(io.BytesIO(ffmpeg_result.stdout), as_attachment=True, download_name='{identifier}.ogg', mimetype="audio/ogg")

	return result

@app.route("/tts-voices")
def voices_list():
	return ["TODO: implement this"]

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
	serve(app, host="0.0.0.0", port=5002, threads=2, backlog=16, connection_limit=24, channel_timeout=10)
