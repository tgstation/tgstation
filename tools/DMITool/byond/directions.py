'''
Created on Feb 23, 2013

@author: Rob
'''
import sys
# NORTH, SOUTH, EAST, and WEST are just #define statements built in DM.  
# They represent 1, 2, 4, and 8

NORTH = 1
SOUTH = 2
EAST = 4
WEST = 8

IMAGE_INDICES=[
    SOUTH,
    NORTH,
    EAST,
    WEST,
    (SOUTH|EAST),
    (SOUTH|WEST),
    (NORTH|EAST),
    (NORTH|WEST)
    ]

def getDirFromName(name):
    return getattr(sys.modules[__name__],name,None)

def getNameFromDir(dir):
    if dir == NORTH:
        return 'NORTH'
    elif dir == SOUTH:
        return 'SOUTH'
    elif dir == EAST:
        return 'EAST'
    elif dir == WEST:
        return 'WEST'
    elif dir == (NORTH|WEST):
        return 'NORTHWEST'
    elif dir == (NORTH|EAST):
        return 'NORTHEAST'
    elif dir == (SOUTH|EAST):
        return 'SOUTHEAST'
    elif dir == (SOUTH|WEST):
        return 'SOUTHWEST'
    else:
        return 'UNKNOWN (%d)' %dir