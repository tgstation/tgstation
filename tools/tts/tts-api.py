import torch
from TTS.api import TTS
import os
import io
import gc
import json
import subprocess

tts = TTS("tts_models/en/vctk/vits", progress_bar=False, gpu=False)

app = Flask(__name__)
request_count = 0;

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
		with torch.no_grad():
			tts.tts_to_file(text=text, speaker=voice, file_path=wav_bytes)

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
	return json.dumps(tts.speakers)

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
