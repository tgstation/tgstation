import os, sys, re
"""
Usage:
    $ python calculateMaxTechLevels.py path/to/your.dme .dm

calculateMaxTechLevels.py - Get techlevels of all objects and generate reports. 

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
REGEX_TECH_ORIGIN = re.compile('^(?P<tabs>\t+)(?:var/)?origin_tech\s*=\s*"(?P<content>.+)"\s*$')
REGEX_ATOMDEF = re.compile('^(?P<tabs>\t*)(?P<atom>[a-zA-Z0-9_/]+)\s*$')

#Calculated Max Tech Levels.
CMTLs = {}

# All known atoms with tech origins.
AtomTechOrigins = {}

def debug(filename, line, path, message):
    print('{0}:{1}: {2} - {3}'.format(filename, line, '/'.join(path), message))

def ProcessFile(filename):
    with open(filename, 'r') as f:
        cpath = []
        popLevels = []
        pindent = 0  # Previous Indent
        ln = 0
        ignoreLevel = []
        debugOn = False
        for line in f:
            ln += 1
            if '/*' in line:
                ignoreLevel += ['*/']
            if '{"' in line:
                ignoreLevel += ['"}']
            if len(ignoreLevel) > 0:
                if ignoreLevel[-1] in line:
                    ignoreLevel.pop()
                continue 
            m = REGEX_ATOMDEF.match(line)
            if m is not None:
                numtabs = len(m.group('tabs'))
                atom = m.group('atom')
                atom_path = m.group('atom').split('/')
                if atom in ('else', 'break', 'return', 'continue', 'spawn', 'proc'):
                    continue
                if atom.startswith('var/') or atom.startswith('//') or (numtabs > 0 and atom.strip().startswith('/')):
                    continue
                
                # Was used to debug a weird path resolution issue with mecha boards.
                #if line.startswith('/obj/item/weapon/circuitboard/mecha'):
                #    debugOn = True
                if debugOn: print('{} > {}'.format(numtabs, line.rstrip()))
                if numtabs == 0:
                    cpath = atom_path
                    if cpath[0] != '':
                        cpath.insert(0, '')
                    popLevels = [len(cpath)]
                    if debugOn: debug(filename, ln, cpath, '0')
                elif numtabs > pindent:
                    cpath += atom_path
                    popLevels += [len(atom_path)]
                    if debugOn: debug(filename, ln, cpath, '>')
                elif numtabs < pindent:
                    for i in range(pindent - numtabs):
                        popsToDo = popLevels.pop()
                        if debugOn: print(' pop {} {}'.format(popsToDo, popLevels))
                        for i in range(popsToDo):
                            cpath.pop()
                            if debugOn: print(repr(cpath))
                    cpath += atom_path
                    if debugOn: debug(filename, ln, cpath, '<')
                elif numtabs == pindent:
                    for i in range(popLevels.pop()):
                        cpath.pop()
                        if debugOn: print(repr(cpath))
                    cpath += atom_path
                    popLevels += [len(atom_path)]
                    if debugOn: debug(filename, ln, cpath, '==')
                pindent = numtabs
                continue
            path = '/'.join(cpath)
            m = REGEX_TECH_ORIGIN.match(line)
            if m is not None:
                tech_origin = {}
                # materials=9;bluespace=10;magnets=3
                techchunks = m.group('content').split(';')
                for techchunk in techchunks:
                    parts = techchunk.split('=')
                    tech = parts[0]
                    level = int(parts[1])
                    tech_origin[tech] = level
                    if tech not in CMTLs:
                        CMTLs[tech] = level
                    if CMTLs[tech] < level:
                        CMTLs[tech] = level
                AtomTechOrigins[path] = tech_origin
        
def ProcessFilesFromDME(dmefile='baystation12.dme', ext='.dm'):
    numFilesTotal = 0
    rootdir = os.path.dirname(dmefile)
    with open(dmefile, 'r') as dmeh:
        for line in dmeh:
            if line.startswith('#include'):
                inString = False
                # escaped=False
                filename = ''
                for c in line:
                    """
                    if c == '\\' and not escaped:
                        escaped = True
                        continue
                    if escaped:
                        if
                        escaped = False
                        continue
                    """         
                    if c == '"':
                        inString = not inString
                        if not inString:
                            filepath = os.path.join(rootdir, filename)
                            if filepath.endswith(ext):
                                # print('Processing {0}...'.format(filepath))
                                ProcessFile(filepath)
                                numFilesTotal += 1
                            filename = ''
                        continue
                    else:
                        if inString:
                            filename += c

if os.path.isdir(sys.argv[1]):
    selectedDMEs = []
    for root, _, files in os.walk(sys.argv[1]):
        for filename in files:
            filepath = os.path.join(root, filename)
            if filepath.endswith('.dme'):
                ProcessFilesFromDME(filepath, sys.argv[2])
                selectedDMEs.append(filepath)
                break
    with open(os.path.join(sys.argv[1], 'tech_origin_list.csv'), 'w') as w:
        with open(os.path.join(sys.argv[1], 'max_tech_origins.txt'), 'w') as mto:
            tech_columns = []
            mto.write('Calculated Max Tech Levels:\n  These tech levels have been determined by parsing ALL origin_tech variables in code included by {0}.\n'.format(', '.join(selectedDMEs)))
            for tech in sorted(CMTLs.keys()):
                tech_columns.append(tech)
                mto.write('{:>15}: {}\n'.format(tech, CMTLs[tech]))
            w.write(','.join(['Atom'] + tech_columns) + "\n")
            for atom in sorted(AtomTechOrigins.keys()):
                techs = []
                for tech in tech_columns:
                    if tech in AtomTechOrigins[atom]:
                        techs.append(str(AtomTechOrigins[atom][tech]))
                    else:
                        techs.append('')
                w.write(','.join([atom] + techs) + "\n")
if os.path.isfile(sys.argv[1]):
    ProcessFilesFromDME(sys.argv[1], sys.argv[2])
