import os, sys, re, subprocess, hashlib, logging
"""
Usage:
    $ python create.py vox_wordlist.txt
    
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
def md5sum(filename):
    md5 = hashlib.md5()
    with open(filename,'rb') as f: 
        for chunk in iter(lambda: f.read(128*md5.block_size), b''): 
             md5.update(chunk)
    return md5.hexdigest()
REGEX_SEARCH_STRINGS = re.compile(r'(\'|")(.*?)(?:\1)')
SOX_ARGS  = 'stretch 1.1'
#SOX_ARGS += ' phaser 0.89 0.85 2 0.24 1 -t'
SOX_ARGS += ' chorus 0.7 0.9 55 0.4 0.25 2 -t'
SOX_ARGS += ' echo 0.8 0.88 6.0 0.4'
SOX_ARGS += ' norm'
#SOX_ARGS += ' reverb'
wordlist=[]
def cmd(command):
	logging.debug('>>> '+command)
	output=''
	try:
		#if subprocess.call(command,shell=True) != 0:
		output = subprocess.check_output(command,stderr=subprocess.STDOUT,shell=True)
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
	"""
	( "walkers" n ((( w oo ) 1) (( k @ z ) 0)) )
	( "present" v ((( p r e ) 0) (( z @ n t ) 1)) )
	( "monument" n ((( m o ) 1) (( n y u ) 0) (( m @ n t ) 0)) )
	"""
	def toLisp(self):
		lispSyllables=[]
		for syllable in self.syllables:
			lispSyllables.append('( ( {0} ) {1} )'.format(syllable[0],syllable[1]))
		return '(lex.add.entry\n\t\'( "{0}" {1} ( {2} ) ))\n'.format(self.name,self.type[0],' '.join(lispSyllables))
		#return '(lex.add.entry ( "{0}" {1} ( {2} ) ))\n'.format(self.name,self.type[0],' '.join(lispSyllables))
		
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
			self.syllables += [(match.group(2), stressLevel)]
		logging.info('Parsed {0} as {1}.'.format(pronunciation,repr(self.syllables)))
	
def GenerateForWord(word,wordfile):
	global wordlist, lexmd5, SOX_ARGS
	if '/' not in word:
		wordlist += [wordfile]
	md5=hashlib.md5(word).hexdigest()
	oggfile = os.path.abspath(os.path.join('sounds',wordfile+'.ogg'))
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
		if old_md5 == md5+lexmd5:
			logging.info('Skipping {0}.ogg (exists)'.format(wordfile))
			return
	logging.info('Generating {0}.ogg ({1})'.format(wordfile,repr(word)))
	with open('tmp/VOX-word.txt','w') as wf:
		wf.write(word)
	
	text2wave = 'text2wave tmp/VOX-word.txt -o tmp/VOX-word.wav'
	if os.path.isfile('tmp/VOXdict.lisp'):
		text2wave = 'text2wave -eval tmp/VOXdict.lisp tmp/VOX-word.txt -o tmp/VOX-word.wav'
	
	with open(cachefile,'w') as wf:
		wf.write(md5+lexmd5)
	cmds=[]
	cmds += [text2wave]
	cmds += ['sox tmp/VOX-word.wav tmp/VOX-sox-word.wav '+SOX_ARGS]
	cmds += ['oggenc tmp/VOX-sox-word.wav -o sounds/'+wordfile+'.ogg']
	for command in cmds:
		if not cmd(command):
			sys.exit(1)

def ProcessWordList(filename):
	with open(filename,'r') as words:
		for line in words:
			if '=' in line and not line.startswith("#"):
				(wordfile,phrase) = line.split('=')
				GenerateForWord(phrase.strip(),wordfile.strip())
def ProcessLexicon(filename):
	with open('tmp/VOXdict.lisp','w') as lisp:
		with open(filename,'r') as lines:
			for line in lines:
				line=line.strip()
				if ':' in line and not line.startswith('#'):
					p = Pronunciation()
					p.parseWord(line)
					lisp.write(p.toLisp())

logging.basicConfig(format='%(asctime)s [%(levelname)-8s]: %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)
if not os.path.isdir('tmp'):
	os.makedirs('tmp')
lexmd5=md5sum('lexicon.txt')
ProcessLexicon('lexicon.txt')
for arg in sys.argv[1:]:
	ProcessWordList(arg)
with open('wordlist.txt','w') as w:
	for word in sorted(wordlist):
		w.write(word+"\n")
