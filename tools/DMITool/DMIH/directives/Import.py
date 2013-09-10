'''
Created on Feb 23, 2013

@author: Rob
'''
from .Directive import Directive

class Import(Directive):
    '''
    Tells the compiler to import a file into the DMI.
    '''
    
    '''
    pngs or dmi.
    '''
    ftype=''
    
    '''
    The file(s) to import into the DMI.
    '''
    filedef=None
    
    '''
    State(s) to import (DMIs)
    '''
    states={}
     
    def __init__(self,name,params):
        Directive.__init__(self,name,params)
        self.ftype=params[0]
        if self.ftype=='pngs':
            self.filedef=params[1]
        elif self.ftype=='dmi':
            self.filedef=str(params[1])
            if type(params[2]) is list:
                for sn in params[2]:
                    self.addState(sn)
            elif type(params[2]) is str:
                self.addState(params[2])
                
    def addState(self,sn):
        oldname=None
        newname=None
        snp=sn.split('->')
        if snp.len == 2:
            (oldname, newname)=snp
        elif snp.len == 1:
            oldname=newname=snp[0]
        if oldname and newname:
            self.states[oldname]=newname