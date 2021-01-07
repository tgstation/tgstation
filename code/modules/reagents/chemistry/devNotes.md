# Things I edited that might break or things I need to do

if you're reading this in the PR. I forgot to remove this or I'm in the middle of testing these things.

- Check the scanner thing in medical and add a invisible check - PASSED
- check failed chem - PASSED
- Return fluro to instant after ensuring foam can't infinite loop - PASSED
    - disabled REACT_INSTANT Do I want it back? Is foam continulously reacting a bad thing?
    - I tested explosive foam - seems fine, the explosion clears reagents so it doesn't cause chaos
- Convert previous_reagents_list into a list of types, not a list of objects - PASSED
- Check over purity conversion - seems to work, slight numbers are off
- Ensure revisions to equilibrium haven't broken it - PASSED
- Multiple product reactions should work now - but I can't find any in code to test. If there are none, atomise out a new chem that produces 2+ to test

- I think botany is okay too, but check a few reactions there
    - I grew a plant and nothing bad happened

- remove debug messages
- make sure plumbing remains functional after conditions to deal with smoke and the optimisations put in

- write the readme
- make the PR!
- make fancy webms to show off effects!
- convert webms because github is dumb and wants gifs

- atomise universal indicator for ghetto chem
- atomise do like an otter, add acid to water (though will plumbing make this too much?)
- atomise beaker changes out that I accidentally pressed push on
- are all the pHes in? Maybe add more? (maybe ask the person reading this if they'd be willing to help suggest pHes for reagents?)
- read over diff