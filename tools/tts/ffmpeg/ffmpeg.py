import os
import io
import gc
import subprocess
from flask import Flask, request, send_file

app = Flask(__name__)

@app.route("/ffmpeg")
def text_to_speech():
	ffmpeg_data = request.data
	filter_complex = request.args.get("filter", "")

	ffmpeg_result = None
	if filter_complex != "":
		ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-filter_complex", filter_complex, "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=ffmpeg_data, capture_output = True)
	else:
		ffmpeg_result = subprocess.run(["ffmpeg", "-f", "wav", "-i", "pipe:0", "-c:a", "libvorbis", "-b:a", "64k", "-f", "ogg", "pipe:1"], input=ffmpeg_data, capture_output = True)
	print(f"ffmpeg result size: {len(ffmpeg_result.stdout)} stderr = \n{ffmpeg_result.stderr.decode()}")

	result = send_file(io.BytesIO(ffmpeg_result.stdout), mimetype="audio/ogg")
	return result

@app.route("/health-check")
def tts_health_check():
	gc.collect()
	return f"OK", 200

if __name__ == "__main__":
	if os.getenv('TTS_LD_LIBRARY_PATH', "") != "":
		os.putenv('LD_LIBRARY_PATH', os.getenv('TTS_LD_LIBRARY_PATH'))
	from waitress import serve
	serve(app, host="0.0.0.0", port=5003, threads=2, backlog=16, connection_limit=24, channel_timeout=10)
