import os, sys, re
"""
Usage:
    $ python fix_string_idiocy.py path/to/your.dme .dm
    
NOTE: NOT PERFECT, CREATES code-fixed DIRECTORY.  
*** MERGE THIS MANUALLY OR YOU WILL BREAK SHIT. ***

fix_string_idiocy.py - Combines multiple string append operations in DreamMaker code

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
REGEX_TO_COMBINE_AS_BLOCK = re.compile('^(?P<tabs>\t+)(?P<declaration>var/)?(?P<identifier>[A-Za-z\.]+)\s*(?P<operator>\+?)=\s*"(?P<content>.+)"\s*$')
def ProcessFile(filename):
    fuckups = []
    with open(filename, 'r') as f:
        lastID = ''
        declaring=False
        lastLevel = 0
        lastWasAlert = False
        buffa = ''
        tempbuffa = ''
        tempfuckup = ''
        tempBackup = ''
        origIndentLevel=0
        ln = 0
        for line in f:
            ln += 1
            m = REGEX_TO_COMBINE_AS_BLOCK.match(line)
            if m is not None:
                level = m.group('tabs').count('\t')
                ID = m.group('identifier')
                content = m.group('content').strip()
                indent = '\t' * level
                #indentMore = '\t' * (level + 1)
                if ID == lastID and level == lastLevel:
                    if not lastWasAlert:
                        buffa += '\n' + indent + '// AUTOFIXED BY fix_string_idiocy.py'
                        buffa += '\n' + indent + '// ' + tempfuckup
                        buffa += '\n' + tempbuffa
                        print(tempfuckup)
                        fuckups.append(tempfuckup)
                    msg = '{0}:{1}: {2}'.format(filename, ln, line.strip())
                    print(msg)
                    fuckups.append(msg)
                    buffa += '\n'
                    #buffa += indentMore
                    buffa += content
                    lastWasAlert = True
                else:
                    if lastWasAlert:
                        buffa += '"}'
                        buffa += '\n' + ('\t'*origIndentLevel) + '// END AUTOFIX'
                        buffa += '\n'
                        lastWasAlert = False
                    if tempBackup != '':
                        buffa += tempBackup
                    tempBackup = line
                    tempbuffa = indent
                    origIndentLevel=level
                    if m.group('declaration') is None:
                        tempbuffa += '{0} {2}= {{"{1}'.format(ID, content, m.group('operator'))
                    else:
                        tempbuffa += 'var/{0} {2}= {{"{1}'.format(ID, content, m.group('operator'))
                    tempfuckup = '{0}:{1}: {2}'.format(filename, ln, line.strip())
                lastID = ID
                lastLevel = level
            else:
                if line.strip() == '':
                    tempBackup += line
                    continue
                if lastWasAlert:
                    buffa += '"}'
                    buffa += '\n' + indent + '// END AUTOFIX'
                    buffa += '\n'
                    lastWasAlert = False
                    tempBackup = ''
                if tempBackup != '':
                    buffa += tempBackup
                    tempBackup = ''
                lastID = ''
                lastLevel = ''
                buffa += line
        fixpath = filename.replace('code' + os.sep, 'code-fixed' + os.sep)
        fixpath = fixpath.replace('interface' + os.sep, 'interface-fixed' + os.sep)
        fixpath = fixpath.replace('RandomZLevels' + os.sep, 'RandomZLevels-fixed' + os.sep)
        if len(fuckups) > 0:
            if not os.path.isdir(os.path.dirname(fixpath)):
                os.makedirs(os.path.dirname(fixpath))
            with open(fixpath, 'w') as fixes:
                fixes.write(buffa)
        else:
            if os.path.isfile(fixpath):
                os.remove(fixpath)
        # print(' Processed - {0} lines.'.format(ln))
        return fuckups
        
def ProcessFilesFromDME(dmefile='baystation12.dme', ext='.dm'):
    numFilesTotal = 0
    fileFuckups = {}
    rootdir = os.path.dirname(dmefile)
    with open(os.path.join(rootdir, 'stringcounts.csv'), 'w') as csv:
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
                                    fileFuckups[filepath] = ProcessFile(filepath)
                                    numFilesTotal += 1
                                filename = ''
                            continue
                        else:
                            if inString:
                                filename += c

if os.path.isdir(sys.argv[1]):
    for root, _, files in os.walk(sys.argv[1]):
        for filename in files:
            filepath = os.path.join(root, filename)
            if filepath.endswith('.dme'):
                ProcessFilesFromDME(filepath, sys.argv[2])
                sys.exit(0)
if os.path.isfile(sys.argv[1]):
    ProcessFilesFromDME(sys.argv[1], sys.argv[2])
