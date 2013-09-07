'''
Created on Feb 23, 2013

@author: Rob
'''

from . import directives, Variable

valid_symbol_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

class DMIH(object):
    """
# DMI Header 1.0
# ------------------------

height    = 32
width     = 32

state "AMAZIN' RAISINS" {
    dirtype=CARDINAL
    frames=5
    
    import pngs {
        direction NORTH {
            "amazinraisin-N-0.png"
            "amazinraisin-N-1.png"
            "amazinraisin-N-2.png"
            "amazinraisin-N-3.png"
            "amazinraisin-N-4.png"
        }
        direction EAST {
            "amazinraisin-E-0.png"
            "amazinraisin-E-1.png"
            "amazinraisin-E-2.png"
            "amazinraisin-E-3.png"
            "amazinraisin-E-4.png"
        }
        direction WEST {
            "amazinraisin-W-0.png"
            "amazinraisin-W-1.png"
            "amazinraisin-W-2.png"
            "amazinraisin-W-3.png"
            "amazinraisin-W-4.png"
        }
        direction SOUTH {
            "amazinraisin-S-0.png"
            "amazinraisin-S-1.png"
            "amazinraisin-S-2.png"
            "amazinraisin-S-3.png"
            "amazinraisin-S-4.png"
        }
    }
}

#          File                  State orig   State new
import dmi "import/ohgodwhy.dmi" "Oh god why" "metroid5"

    """

    tokens = []
    
    '''
    directive arg1 {block}
    '''
    directives = {
        'direction': directives.Direction.Direction,
        'import': directives.Import.Import,
        'state': directives.State.State
    }

    def parse(self, file):
        with open(file) as f:
            self.tokens = self.parseBlockContents(f)
            
    def readSymbol(self, f):
        f.seek(f.tell() - 1)  # Back up one char
        o = ''
        while True:
            c = f.read(1)
            if c in valid_symbol_chars:
                o += c
            else:
                return o
            
    def readString(self, f, b):
        # f.seek(f.tell()-1) # Back up one char
        o = ''
        while True:
            c = f.read(1)
            if c == b:
                return o
            else:
                o += c
            
    def parseBlockContents(self, f):
        buf = ''
        currentBlock = []
        memory = []
        _in = None
        memchanged = False
        while True:
            b = f.read(1)  # .decode('utf-8')
            if b in ('"', "'"):
                memory += [self.readString(f, b)]
                memchanged = True
                
            if b in valid_symbol_chars:
                memory += [self.readSymbol(f)]
                f.seek(f.tell() - 1)  # Back up one char in case we have to deal with a block.
                memchanged = True
                
            if b == '=':
                memory += ['=']
                memchanged = True
                
            if b == '{':
                memory += [self.parseBlockContents(f)]
                memchanged = True
                
            if b == '}' or b == '':  # End of block or end of file.
                return currentBlock
            
            if memchanged:
                token = None
                if len(memory) == 3:
                    if memory[2] == '=':
                        token = Variable(memory[0], memory[1])
                if len(memory) > 0:
                    if memory[0] in self.directives:
                        token = self.directives[memory[0]](memory[0], memory[1:])
                if token:
                    currentBlock += [token]
                    memory = []
                    memchanged = False
        
