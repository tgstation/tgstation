import os, sys, re, subprocess, hashlib, logging
"""
Usage:
    $ python create.py voxwords.txt
    
Requires festival, sox, and vorbis-tools.

create.py - Uses festival to generate word oggs.

Copyright 2013 Rob "N3X15" Nelson <nexis@7chan.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

###############################################
## CONFIG
###############################################

##Voice you want to use 
#VOICE='rab_diphone'
# This is the nitech-made ARCTIC voice, tut on how to install: 
# http://ubuntuforums.org/showthread.php?t=751169 ("Installing the enhanced Nitech HTS voices" section)
#VOICE='nitech_us_bdl_arctic_hts'
#VOICE='nitech_us_jmk_arctic_hts'
#VOICE='nitech_us_awb_arctic_hts'
VOICE='nitech_us_slt_arctic_hts' # less bored US female
#VOICE='nitech_us_clb_arctic_hts' # DEFAULT, bored US female (occasionally comes up with british pronunciations?!)
#VOICE='nitech_us_rms_arctic_hts'

#PHONESET='mrpa'
PHONESET=''

# What we do with SoX:
SOX_ARGS  = '' 
SOX_ARGS += ' pitch -500'
SOX_ARGS += ' stretch 1.2' # Starts the gravelly sound, lowers pitch a bit.
#SOX_ARGS += ' synth tri fmod 60'
SOX_ARGS += ' synth sine amod 60'
#SOX_ARGS += ' synth tri amod 60'
SOX_ARGS += ' chorus 0.7 0.9 55 0.4 0.25 2 -t'
SOX_ARGS += ' phaser 0.9 0.85 4 0.23 1.3 -s'
SOX_ARGS += ' bass -40'
SOX_ARGS += ' highpass 22 highpass 22'
SOX_ARGS += ' compand 0.01,1 -90,-90,-70,-70,-60,-20,0,0 -5 -20' # Dynamic range compression.
SOX_ARGS += ' echos 0.8 0.5 100 0.25 10 0.25' # Good with stretch, otherwise sounds like bees.
#SOX_ARGS += ' delay 0.5'
SOX_ARGS += ' norm'

# Have to do the trimming seperately.
PRE_SOX_ARGS = 'trim 0 -0.1' # Trim off last 0.2s.

# Shit we shouldn't change or overwrite. (Boops, pauses, etc)
preexisting = {
	'.':1,
	',':1,
	'bloop':1,
	'bizwarn':1, # Is this a misspelling of the below?
	'buzwarn':1,
	'doop':1,
	'dadeda':1,
	'woop':1,
}

################################################
## ROB'S AWFUL CODE BELOW (cleanup planned)
################################################

REGEX_SEARCH_STRINGS = re.compile(r'(\'|")(.*?)(?:\1)')

othersounds=[]

known_phonemes={}
wordlist = dict(preexisting.items())

def md5sum(filename):
    md5 = hashlib.md5()
    with open(filename,'rb') as f: 
        for chunk in iter(lambda: f.read(128*md5.block_size), b''): 
             md5.update(chunk)
    return md5.hexdigest()

def cmd(command):
	logging.debug('>>> '+command)
	output=''
	try:
		#if subprocess.call(command,shell=True) != 0:
		output = subprocess.check_output(command,stderr=subprocess.STDOUT,shell=True)
		logging.debug(output)
		return True
	except Exception as e:
		logging.error(output)
		logging.error(e)
		return False
	
class Pronunciation:
	def __init__(self):
		self.syllables=[]
		self.name=[]
		self.type='n'
		self.phoneConv = {
			'mrpa': {
				'ae': 'a',
				'ih': 'i',
			}
		}
		# DMU phonemes + pau
		self.validPhonemes=[
			'aa',
			'ae',
			'ah',
			'ao',
			'aw',
			'ay',
			'b',
			'ch',
			'd',
			'dh',
			'eh',
			'er',
			'ey',
			'f',
			'g',
			'hh',
			'ih',
			'iy',
			'jh',
			'k',
			'l',
			'm',
			'n',
			'ng',
			'ow',
			'oy',
			'p',
			'r',
			's',
			'sh',
			't',
			'th',
			'uh',
			'uw',
			'v',
			'w',
			'y',
			'z',
			'zh',
			'pau']
	"""
	( "walkers" n ((( w oo ) 1) (( k @ z ) 0)) )
	( "present" v ((( p r e ) 0) (( z @ n t ) 1)) )
	( "monument" n ((( m o ) 1) (( n y u ) 0) (( m @ n t ) 0)) )
	"""
	def toLisp(self):
		lispSyllables=[]
		for syllable in self.syllables:
			lispSyllables.append('( ( {0} ) {1} )'.format(' '.join(syllable[0]),syllable[1]))
		return '(lex.add.entry\n\t\'( "{0}" {1} ( {2} ) ))\n'.format(self.name,self.type[0],' '.join(lispSyllables))
		
	"""
	walkers: noun "w oo" 'k @ z'
	present: verb 'p r e' "z @ n t"
	monument: noun "mo" 'n y u' 'm @ n t'
	"""
	def parseWord(self,line):
		global REGEX_SEARCH_STRINGS
		lineChunks=line.split(' ')
		self.name=lineChunks[0].strip(':')
		self.type=lineChunks[1].strip()
		pronunciation=' '.join(lineChunks[2:])
		for match in REGEX_SEARCH_STRINGS.finditer(pronunciation):
			stressLevel=0
			if match.group(1) == '"':
				stressLevel=1
			phonemes=[]
			for phoneme in match.group(2).split(' '):
				if phoneme not in self.validPhonemes:
					logging.error('INVALID PHONEME "{0}" IN LEX ENTRY "{1}"'.format(phoneme,self.name))
					sys.exit(1)
				if PHONESET in self.phoneConv:
					phoneset = self.phoneConv[PHONESET]
					if phoneme in phoneset:
						phoneme = phoneset[phoneme]
				phonemes += [phoneme]
			self.syllables += [(phonemes, stressLevel)]
		logging.info('Parsed {0} as {1}.'.format(pronunciation,repr(self.syllables)))
	
def GenerateForWord(word,wordfile):
	global wordlist, preexisting, SOX_ARGS, known_phonemes, othersounds
	my_phonemes={}
	if wordfile in preexisting:
		logging.info('Skipping {0}.ogg (Marked as PRE_EXISTING)'.format(wordfile))
		return
	if '/' not in wordfile:
		wordlist[wordfile] = len(word.split(' '))
	else:
		othersounds += [wordfile]
	md5=hashlib.md5(word).hexdigest()
	for w in word.split(' '):
		w=w.lower()
		if w in known_phonemes:
			my_phonemes[w]=known_phonemes[w].toLisp().replace('\n','')
	md5 += '\n'.join(my_phonemes.values())
	md5 += SOX_ARGS + PRE_SOX_ARGS
	oggfile = os.path.abspath(os.path.join('sound','vox_fem',wordfile+'.ogg'))
	if '/' in wordfile:
		oggfile = os.path.abspath(os.path.join(wordfile+'.ogg'))
	cachefile = os.path.abspath(os.path.join('cache',wordfile.replace(os.sep,'_').replace('.','')+'.dat'))
	
	parent = os.path.dirname(oggfile)
	if not os.path.isdir(parent):
		os.makedirs(parent)
	
	parent = os.path.dirname(cachefile)
	if not os.path.isdir(parent):
		os.makedirs(parent)
	
	if os.path.isfile(oggfile):
		old_md5 = ''
		if os.path.isfile(cachefile):
			with open(cachefile,'r') as md5f:
				old_md5=md5f.read()
		if old_md5 == md5:
			logging.info('Skipping {0}.ogg (exists)'.format(wordfile))
			return
	logging.info('Generating {0}.ogg ({1})'.format(wordfile,repr(word)))
	with open('tmp/VOX-word.txt','w') as wf:
		wf.write(word)
	
	text2wave = 'text2wave tmp/VOX-word.txt -o tmp/VOX-word.wav'
	if os.path.isfile('tmp/VOXdict.lisp'):
		text2wave = 'text2wave -eval tmp/VOXdict.lisp tmp/VOX-word.txt -o tmp/VOX-word.wav'
	
	with open(cachefile,'w') as wf:
		wf.write(md5)
	for fn in ('tmp/VOX-word.wav','tmp/VOX-soxpre-word.wav','tmp/VOX-sox-word.wav'):
		if os.path.isfile(fn):
			os.remove(fn)
	cmds=[]
	cmds += [(text2wave,'tmp/VOX-word.wav')]
	cmds += [('sox tmp/VOX-word.wav tmp/VOX-soxpre-word.wav '+PRE_SOX_ARGS,'tmp/VOX-soxpre-word.wav')]
	cmds += [('sox tmp/VOX-soxpre-word.wav tmp/VOX-sox-word.wav '+SOX_ARGS,'tmp/VOX-sox-word.wav')]
	cmds += [('oggenc tmp/VOX-sox-word.wav -o '+oggfile,oggfile)]
	for command_spec in cmds:
		(command, cfn)=command_spec
		if not cmd(command):
			sys.exit(1)
	for command_spec in cmds:
		(command, cfn)=command_spec
		if not os.path.isfile(fn):
			logging.error("File '{0}' doesn't exist, command '{1}' probably failed!".format(cfn,command))
			sys.exit(1)
	

def ProcessWordList(filename):
	toprocess={}
	with open(filename,'r') as words:
		for line in words:
			if line.startswith("#"):
				continue
			if line.strip() == '':
				continue
			if '=' in line:
				(wordfile,phrase) = line.split('=')
				toprocess[wordfile.strip()]=phrase.strip()
			elif line != '' and ' ' not in line and len(line) > 0:
				word = line.strip()
				toprocess[word]=word
	for wordfile,phrase in iter(sorted(toprocess.iteritems())):
		GenerateForWord(phrase,wordfile)
		
def ProcessLexicon(filename):
	global known_phonemes, VOICE
	with open('tmp/VOXdict.lisp','w') as lisp:
		if VOICE != '':
			lisp.write('(voice_{0})\n'.format(VOICE))
		with open(filename,'r') as lines:
			for line in lines:
				line=line.strip()
				if ':' in line and not line.startswith('#'):
					p = Pronunciation()
					p.parseWord(line)
					lisp.write(p.toLisp())
					known_phonemes[p.name]=p

logging.basicConfig(format='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
if not os.path.isdir('tmp'):
	os.makedirs('tmp')
CODE_BASE=os.path.join('code','defines')
if not os.path.isdir(CODE_BASE):
	os.makedirs(CODE_BASE)
ProcessLexicon('lexicon.txt')
for arg in sys.argv[1:]:
	ProcessWordList(arg)
soundsToKeep=set()
for sound in othersounds:
	soundsToKeep.add(sound+'.ogg')
with open(os.path.join(CODE_BASE,'vox_sounds.dm'),'w') as w:
	w.write("// AUTOMATICALLY GENERATED, DO NOT EDIT.\n")
	w.write("// List is required to compile the resources into the game when it loads.\n")
	w.write("// Dynamically loading it has bad results with sounds overtaking each other, even with the wait variable.\n")
	w.write("var/list/vox_sounds = list(\n")
	for word,wordlen in sorted(wordlist.items()):
		if '/' in word:
			continue
		filename=''
		if word in preexisting:
			filename = 'sound/vox/{0}.wav'.format(word)
		else:
			filename = 'sound/vox_fem/{0}.ogg'.format(word)
		w.write('\t"{0}" = \'{1}\',\n'.format(word,filename))
		soundsToKeep.add(filename)
	w.write(')')
	w.write('\n\n// How long each "word" really is (in words).  Single-word phrases are skipped for brevity.')
	w.write('\nvar/list/vox_wordlen = list(\n')
	for word,wordlen in sorted(wordlist.items()):
		if wordlen == 1: continue
		if '/' in word:
			continue
		w.write('\t"{0}" = {1},\n'.format(word,wordlen))
	w.write(')')


for root, dirs, files in os.walk('sound/', topdown=False):
    for name in files:
	filename = os.path.join(root,name)
	if filename not in soundsToKeep:
		logging.warning('Removing {0} (no longer defined)'.format(filename))
		os.remove(filename)