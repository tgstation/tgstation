#!/usr/bin/env python
'''
Run within icons/mob/in-hand.

Usage:
    $ cd icons/mob/in-hands
    $ python ss13_makeinhands.py

ss13_makeinhands.py - Generates a large DMI from several smaller DMIs.
    Specifically used for making icons/mob/items_(left|right)hand.dmi

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
'''
import os, sys, logging

ToBuild = {
#   ' file to build':         'directory to pull from/',
    '../items_lefthand.dmi':  'left/',
    '../items_righthand.dmi': 'right/'
}

# Tell Python where to find BYONDTools.
# Assuming we're in icons/mob/in-hand
sys.path.append('../../../tools/BYONDTools')  # For byond
sys.path.append('../../../tools/BYONDTools/scripts')  # For dmi

from byond.DMI import DMI
from dmi import compare_all

def buildDMI(directory, output):
    dmi = DMI(output)
    logging.info('Creating {0}...'.format(output))
    for root, _, files in os.walk(directory):
        for filename in files:
            if filename.endswith('.dmi') and not filename.endswith('.new.dmi'):
                filepath = os.path.join(root, filename)
                logging.info('Adding {0}...'.format(filename, output))
                subdmi = DMI(filepath)
                subdmi.loadAll()
                if subdmi.icon_height != 32 or subdmi.icon_width != 32:
                    logging.warn('Skipping {0} - Invalid icon size.'.format(filepath))
                changes = 0
                for state_name in subdmi.states:
                    if state_name in dmi.states:
                        logging.warn('Skipping state {0}:{1} - State exists.'.format(filepath, subdmi.states[state_name].displayName()))
                        continue
                    dmi.states[state_name] = subdmi.states[state_name]
                    changes += 1
                logging.info('Added {0} states.'.format(changes))
    # save
    logging.info('Saving {0} states to {1}...'.format(len(dmi.states), output))
    dmi.save(output)
    
if __name__ == '__main__':
    logging.basicConfig(
        format='%(asctime)s [%(levelname)-8s]: %(message)s',
        datefmt='%m/%d/%Y %I:%M:%S %p',
        level=logging.INFO  # ,
        # filename='logs/main.log',
        # filemode='w'
        )
    # Cheating, but useful for checking for unsync'd stuff
    compare_all('left/', 'right/', 'in-hand_sync_report.txt', None, newfile_theirs=False, newfile_mine=False, check_changed=False)
    for output, input_dir in ToBuild.items():
        buildDMI(input_dir, output)