#!/usr/bin/env python

import subprocess
import os
import sys
from subprocess import PIPE, STDOUT

null = open("/dev/null", "wb")

def wait(p):
    rc = p.wait()
    if rc != 0:
        p = play("sound/misc/compiler-failure.ogg")
        p.wait()
        assert p.returncode == 0
        sys.exit(rc)

def play(soundfile):
    p = subprocess.Popen(["play", soundfile], stdout=null, stderr=null)
    assert p.wait() == 0
    return p

p = subprocess.Popen("(cd tgui; /bin/bash ./build.sh)", shell=True)
wait(p)
play("sound/misc/compiler-stage1.ogg")

p = subprocess.Popen("DreamMaker tgstation.dme", shell=True)
wait(p)
play("sound/misc/compiler-stage2.ogg")

p = subprocess.Popen(
    "DreamDaemon tgstation.dmb 25001 -trace -trusted 2>&1 | tee server.log~",
    shell=True, stdout=PIPE, stderr=STDOUT)
while p.returncode is None:
    stdout, stderr = p.communicate()
    if "Initializations complete." in stdout:
        play("sound/misc/server-ready.ogg")
