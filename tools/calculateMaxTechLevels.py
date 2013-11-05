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
REGEX_VARIABLE = re.compile('^(?P<tabs>\t+)(?:var/)?(?P<type>[a-zA-Z0-9_]*/)?(?P<variable>[a-zA-Z0-9_]+)\s*=\s*(?P<qmark>[\'"])(?P<content>.+)(?P=qmark)\s*$')
REGEX_ATOMDEF = re.compile('^(?P<tabs>\t*)(?P<atom>[a-zA-Z0-9_/]+)\s*$')

#Calculated Max Tech Levels.
CMTLs = {}

# All known atoms with tech origins.
AtomTechOrigins = {}
Atoms={}
Nodes={}

class BYONDFileRef:
    """
    Just to format file references differently.
    """
    def __init__(self,string):
        self.value=string
        
    def __repr__(self):
        return "'{0}'".format(self.value)

class BYONDString:
    """
    Just to format file references differently.
    """
    def __init__(self,string):
        self.value=string
        
    def __repr__(self):
        return '"{0}"'.format(self.value)
    
class Atom:
    def __init__(self,path):
        self.path=path
        self.properties={}
        self.children={}
        self.parent=None

    def InheritProperties(self):
        if self.parent:
            for key,value in self.parent.properties.items():
                if key not in self.properties:
                    self.properties[key]=value
        for k in self.children.iterkeys():
            self.children[k].InheritProperties()

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
                
                # Reserved words that show up on their own
                if atom in ('else', 'break', 'return', 'continue', 'spawn', 'proc'):
                    continue
                
                # Other things to ignore (false positives, comments)
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
            """
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
            """
            m = REGEX_VARIABLE.match(line)
            if m is not None:
                if path not in Atoms:
                    Atoms[path] = Atom(path)
                name=m.group('variable')
                content=m.group('content')
                qmark=m.group('qmark')
                if qmark == '"':
                    Atoms[path].properties[name]=BYONDString(content)
                else:
                    Atoms[path].properties[name]=BYONDFileRef(content)
    
def Nodify(root='/',parent=None):
    Branch={}
    root_path=root.split('/')
    for path in Atoms.keys():
        cpath=path.split('/')
        if path.startswith(root) and (len(cpath)-len(root_path)) == 1:
            nodeName=cpath[-1]
            Branch[nodeName]=Atoms[path]
            Branch[nodeName].parent=parent
            Branch[nodeName].children=Nodify(path,Branch[nodeName])
    return Branch

def MakeTree():
    AtomTree=Atom('/')
    for key in Atoms:
        atom=Atoms[key]
        cpath=[]
        cNode=AtomTree
        fullpath=atom.path.split('/')
        truncatedPath=fullpath[1:]
        for path_item in truncatedPath:
            cpath+=[path_item]
            cpath_str='/'.join(['']+cpath)
            #if path_item == 'var':
            #    if path_item not in cNode.properties:
            #        cNode.properties[fullpath[-1]]='???'
            if path_item not in cNode.children:
                if cpath_str in Atoms:
                    cNode.children[path_item] = Atoms[cpath_str]
                else:
                    cNode.children[path_item]=Atom('/'.join(['']+cpath))
                cNode.children[path_item].parent=cNode
            cNode=cNode.children[path_item]
    AtomTree.InheritProperties()
    return AtomTree

def ProcessTechLevels(atom,path=''):
    global CMTLs, AtomTechOrigins, path2name
    for key,val in atom.properties.iteritems():
        if key == 'name':
            path2name[path]=val.value
        elif key == 'origin_tech':
            tech_origin = {}
            # materials=9;bluespace=10;magnets=3
            techchunks = val.value.split(';')
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
            break
    for key,child in atom.children.iteritems():
        ProcessTechLevels(child,path+'/'+key)

def prettify(tree, indent=0):
    prefix=' '*indent
    for key in tree.iterkeys():
        atom=tree[key]
        print('{}{}/'.format(prefix,key))
        prettify(atom.children,indent+len(key))
        for propkey,value in atom.properties.iteritems():
            print('{}var/{} = {}'.format(' '*(indent+len(key)),propkey,repr(value)))
        
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
    tree = MakeTree()
    path2name={}
    ProcessTechLevels(tree)
    with open(os.path.join(sys.argv[1], 'tech_origin_list.csv'), 'w') as w:
        with open(os.path.join(sys.argv[1], 'max_tech_origins.txt'), 'w') as mto:
            tech_columns = []
            mto.write('Calculated Max Tech Levels:\n  These tech levels have been determined by parsing ALL origin_tech variables in code included by {0}.\n'.format(', '.join(selectedDMEs)))
            for tech in sorted(CMTLs.keys()):
                tech_columns.append(tech)
                mto.write('{:>15}: {}\n'.format(tech, CMTLs[tech]))
            w.write(','.join(['Atom','Name'] + tech_columns) + "\n")
            for atom in sorted(AtomTechOrigins.keys()):
                row = []
                row.append(atom)
                row.append('"'+path2name.get(atom,"").replace('"','""')+'"')
                for tech in tech_columns:
                    if tech in AtomTechOrigins[atom]:
                        row.append(str(AtomTechOrigins[atom][tech]))
                    else:
                        row.append('')
                w.write(','.join(row) + "\n")
    #prettify(tree.children)
if os.path.isfile(sys.argv[1]):
    ProcessFilesFromDME(sys.argv[1], sys.argv[2])
