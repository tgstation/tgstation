import os, sys
"""
Usage:
    $ python countstrings.py path/to/your.dme .dm

CountStrings.py - Counts strings in DreamMaker code

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
def CountStringsIn(f):
    numStrings = 0
    inString = False
    escaped = False
    while(True):
        c = f.read(1)
        if not c:
            return numStrings
        if c == '\\' and not escaped:
            escaped = True
            continue
        if escaped:
            escaped = False
            continue         
        if c == '"':
            inString = not inString
            if not inString:
                numStrings += 1
            continue
    return numStrings

def ProcessFiles(top='.', ext='.dm'):
    numStringsTotal = 0
    numStrings = 0
    numFilesTotal = 0
    maxStringsInFile = [0, '']
    for root, _, files in os.walk(top):
        for filename in files:
            filepath = os.path.join(root, filename)
            if filepath.endswith(ext):
                with open(filepath, 'r') as f:
                    numStrings = CountStringsIn(f)
                    numStringsTotal += numStrings
                    if numStrings > maxStringsInFile[0]:
                        maxStringsInFile = [numStrings, filepath]
                    numFilesTotal += 1
                print(','.join([filepath, str(numStrings)]))
    print('>>> Total Strings: {0}'.format(numStringsTotal))
    print('>>> Total Files:   {0}'.format(numFilesTotal))
    print('>>> Max Strings:   {0} in {1}'.format(maxStringsInFile[0], maxStringsInFile[1]))

def ProcessFilesFromDME(dmefile='baystation12.dme', ext='.dm'):
    numStringsTotal = 0
    numStrings = 0
    numFilesTotal = 0
    maxStringsInFile = [0, '']
    rootdir = os.path.dirname(dmefile)
    with open(os.path.join(rootdir,'stringcounts.csv'),'w') as csv:
        with open(dmefile,'r') as dmeh:
            for line in dmeh:
                if line.startswith('#include'):
                    inString = False
                    #escaped=False
                    filename=''
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
                                    with open(filepath, 'r') as f:
                                        numStrings = CountStringsIn(f)
                                        numStringsTotal += numStrings
                                        if numStrings > maxStringsInFile[0]:
                                            maxStringsInFile = [numStrings, filepath]
                                        numFilesTotal += 1
                                    csv.write(','.join([filepath, str(numStrings)])+"\n")
                                filename=''
                            continue
                        else:
                            if inString:
                                filename += c
    print('>>> Total Strings: {0}'.format(numStringsTotal))
    print('>>> Total Files:   {0}'.format(numFilesTotal))
    print('>>> Max Strings:   {0} in {1}'.format(maxStringsInFile[0], maxStringsInFile[1]))

if os.path.isdir(sys.argv[1]):
    for root, _, files in os.walk(sys.argv[1]):
        for filename in files:
            filepath = os.path.join(root, filename)
            if filepath.endswith('.dme'):
                ProcessFilesFromDME(filepath,sys.argv[2])
                sys.exit(0)
if os.path.isfile(sys.argv[1]):
    ProcessFilesFromDME(sys.argv[1],sys.argv[2])
#ProcessFiles(sys.argv[1], sys.argv[2])