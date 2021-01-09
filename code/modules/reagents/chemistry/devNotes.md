# Things I edited that might break or things I need to do

if you're reading this in the PR. I forgot to remove this or I'm in the middle of testing these things.

- Return fluro to instant after ensuring foam can't infinite loop - PASSED
    - disabled REACT_INSTANT Do I want it back? Is foam continulously reacting a bad thing?
    - I tested explosive foam - seems fine, the explosion clears reagents so it doesn't cause chaos

- Multiple product reactions should work now - but I can't find any in code to test. If there are none, atomise out a new chem that produces 2+ to test

- I think botany is okay too, but check a few reactions there
    - I grew a plant and nothing bad happened

- Look at chem goggles and add pH and extra for them

- remove debug messages
- make sure plumbing remains functional after conditions to deal with smoke and the optimisations put in

- atomise universal indicator for ghetto chem
- atomise do like an otter, add acid to water (though will plumbing make this too much?)
- atomise beaker changes out - done
- are all the pHes in? Maybe add more? (maybe ask the person reading this if they'd be willing to help suggest pHes for reagents?)