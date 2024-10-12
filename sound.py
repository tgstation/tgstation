import os
import subprocess

curDir = os.getcwd()
oldSoundDir = curDir + "\\sound"
for dirName, subDirs, files in os.walk(oldSoundDir):
	for subDir in subDirs:
		partialPath = os.path.relpath(os.path.join(dirName, subDir), curDir)
		partialPathNew = os.path.join("sound_new", os.path.relpath(os.path.join(dirName, subDir), oldSoundDir))
		print(partialPath)
		print(partialPathNew)
		subprocess.run(["mkdir", partialPathNew], shell = True)
	for file in files:
		if (os.path.splitext(file)[1] != ".ogg"):
			continue
		partialPath = os.path.relpath(os.path.join(dirName, file), curDir)
		partialPathNew = os.path.join("sound_new", os.path.relpath(os.path.join(dirName, file), oldSoundDir))
		print(partialPath)
		print(partialPathNew)
		subprocess.run(["optivorbis", partialPath, partialPathNew], shell = True)