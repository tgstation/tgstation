//ninjacost() specificCheck defines
#define N_STEALTH_CANCEL 1
#define N_ADRENALINE 2

//ninjaDrainAct() defines for non numerical returns
#define INVALID_DRAIN "INVALID" //This one is if the drain proc needs to cancel, eg missing variables, etc, it's important.
#define DRAIN_RD_HACK_FAILED "RDHACKFAIL"
#define DRAIN_MOB_SHOCK "MOBSHOCK"
#define DRAIN_MOB_SHOCK_FAILED "MOBSHOCKFAIL"

//Tells whether or not someone is a space ninja
#define IS_SPACE_NINJA(ninja) (ninja.mind && ninja.mind.has_antag_datum(/datum/antagonist/ninja))
