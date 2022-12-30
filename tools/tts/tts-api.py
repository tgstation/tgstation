from flask import Flask, request, send_file
import torch
from TTS.api import TTS
import os
import json
import shlex

tts = TTS("tts_models/en/vctk/vits", progress_bar=False, gpu=False)

app = Flask(__name__)

@app.route("/tts")
def text_to_speech():
    voice = request.args.get("voice", '')
    text = request.json.get("text", '')
    identifier = bytes.fromhex(request.args.get("identifier", '')).hex()
    filter_complex = request.args.get("filter", '')
    filter_complex = filter_complex.replace("\"", "")

    filter_statement = ""
    if filter_complex != "":
        filter_statement = "-filter_complex " + shlex.quote(filter_complex)

    wav_file_loc = f'/tts_files/{identifier}.wav'
    ogg_file_loc = f'/tts_files/{identifier}.ogg'

    with torch.no_grad():
        tts.tts_to_file(text=text, speaker=voice, file_path=f"/tts_files/{identifier}.wav")
    os.system(f"ffmpeg -i {shlex.quote(wav_file_loc)} {filter_statement} -c:a libvorbis -b:a 64k {shlex.quote(ogg_file_loc)} -y")
    os.remove(wav_file_loc)
    return send_file(ogg_file_loc, mimetype="audio/wav")

@app.route("/tts-voices")
def voices_list():
    return json.dumps(tts.speakers)

if __name__ == "__main__":
    from waitress import serve
    serve(app, host="0.0.0.0", port=5002)
