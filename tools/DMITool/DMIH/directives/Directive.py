'''
Created on Feb 23, 2013

@author: Rob
'''

class Directive(object):
    '''
    Base type for directives.
    '''
    name = ''
    
    def __init__(self,name,args):
        self.name=name