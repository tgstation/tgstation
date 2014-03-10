'''
Created on Feb 28, 2014

@author: Rob
'''
import os, sys, logging

ToBuild={
#   ' file to build':         'directory to pull from/',
    '../items_lefthand.dmi':  'left/',
    '../items_righthand.dmi': 'right/'
}

# Tell Python where to find OpenBYOND.
# Assuming we're in icons/mob/in-hand
sys.path.append('../../../tools/OpenBYOND/src')

from com.byond.DMI import DMI
from DMITool import compare_all

def buildDMI(directory, output):
    dmi = DMI(output)
    logging.info('Creating {0}...'.format(output))
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith('.dmi') and not filename.endswith('.new.dmi'):
                filepath = os.path.join(root,filename)
                logging.info('Adding {0}...'.format(filename,output))
                subdmi = DMI(filepath)
                subdmi.loadAll()
                if subdmi.icon_height!=32 or subdmi.icon_width!=32:
                    logging.warn('Skipping {0} - Invalid icon size.'.format(filepath))
                changes = 0
                for state_name in subdmi.states:
                    if state_name in dmi.states:
                        logging.warn('Skipping state {0}:{1} - State exists.'.format(filepath,state_name))
                        continue
                    dmi.states[state_name]=subdmi.states[state_name]
                    changes += 1
                logging.info('Added {0} states.'.format(changes))
    #save
    logging.info('Saving {0} states to {1}...'.format(len(dmi.states),output))
    dmi.save(output)
if __name__ == '__main__':
    logging.basicConfig(
        format='%(asctime)s [%(levelname)-8s]: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p', 
        level=logging.INFO)
    # Cheating, but useful for checking for unsync'd stuff
    compare_all('left/','right/','in-hand_sync_report.txt',None,newfile_theirs=False,newfile_mine=False)
    for output, input_dir in ToBuild.items():
        buildDMI(input_dir,output)