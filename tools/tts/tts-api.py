from flask import Flask, request, send_file
from TTS.api import TTS
import os
import json

tts = TTS("tts_models/en/vctk/vits")

app = Flask(__name__)

@app.route("/tts")
def text_to_speech():
    voice = request.args.get("voice", '')
    text = request.json.get("text", '')
    identifier = request.args.get("identifier", 'invalid')
    filter_complex = request.args.get("filter", '')
    filter_complex = filter_complex.replace("\"", "")

    filter_statement = ""
    if filter_complex != "":
        filter_statement = "-filter_complex \"" + filter_complex + "\""

    tts.tts_to_file(text=text, speaker=voice, file_path=f"/tts_files/{identifier}.wav")
    os.system(f"ffmpeg -i '/tts_files/{identifier}.wav' {filter_statement} -c:a libvorbis -b:a 64k '/tts_files/{identifier}.ogg' -y")
    os.remove(f"/tts_files/{identifier}.wav")
    return send_file(f"/tts_files/{identifier}.ogg", mimetype="audio/wav")

@app.route("/tts-voices")
def voices_list():
    return json.dumps(tts.speakers)

if __name__ == "__main__":
    from waitress import serve
    serve(app, host="0.0.0.0", port=5002)
