//Master plumbing tank defines go below here.
#define PLUMBING_TANK_IDLE "Idle" //Not doing anything.
#define PLUMBING_TANK_SYNTHESIZE "Synthesize" //Synthesizing reagents using the buffer as a guideline.
#define PLUMBING_TANK_DRAIN "Drain" //Draining all the reagents from itself.

//Construction defines to ghere.
#define PLUMBING_TANK_FUNCTIONING 0
#define PLUMBING_TANK_BURST 3 //Critical structural damage means that we need more metal to reinforce us.
#define PLUMBING_TANK_NEEDS_WELD 2 //Some welding to reinforce critical parts that need to be repaired.
#define PLUMBING_TANK_NEEDS_WRENCH 1 //And some tightening to fix it up.
