'''
Created on Feb 23, 2013

@author: Rob
'''
from .Directive import Directive
from .Import import Import
from DMI import State
from .. import Variable

directly_assignable={
    'hotspot':tuple,
    'dirs':int,
    'frames':int,
    'movement':int,
    'loop':int,
    'rewind':int,
    'delay':tuple
}

class State(Directive):
    '''
    Tells the compiler to create a state with the specified variables and frames.
    '''
    
    '''
    The actual state
    '''
    state = None
    imports = []
    def __init__(self,name,params):
        Directive.__init__(self,name,params)
        self.state=State()
        if params.len != 2:
            raise Exception('state directive requires 2 parameters.  state "name" { }')
        self.state.name=params[0]
        for o in params[1]:
            if type(o) is Variable and o.name in directly_assignable:
                if o.name == 'dirs':
                    if o.value == 'CARDINAL':
                        o.value = 4
                    elif o.value == 'ALL':
                        o.value = 8
                    else:
                        o.value = 1
                setattr(self.state,o.name,directly_assignable[o.name](o.value)) 
            if type(o) is Import:
                if o.ftype == 'pngs':
                    for dirblock in o.filedef:
                        for i in range(dirblock.frames.len):
                            self.state.setFrame(dirblock.dir, i, dirblock.frames[i])