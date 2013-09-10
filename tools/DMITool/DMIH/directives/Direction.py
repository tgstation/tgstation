'''
Created on Feb 23, 2013

@author: Rob
'''
from .Directive import Directive
from byond import directions
 
class Direction(Directive):
    '''
    Tells the compiler which frames will be used for this direction.
    '''
    
    '''
    Which direction?
    '''
    dir=0
    
    '''
    List of files.
    '''
    frames=[]
    def __init__(self,name,frames):
        Directive.__init__(self, name, [name,frames])
        _dir = directions.getDirFromName(name)
        if _dir:
            self.dir=_dir
        self.frames=frames