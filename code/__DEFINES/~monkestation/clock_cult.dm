#define SPELLTYPE_ABSTRACT "Abstract"
#define SPELLTYPE_SERVITUDE "Servitude"
#define SPELLTYPE_PRESERVATION "Preservation"
#define SPELLTYPE_STRUCTURES "Structures"

#define SIGIL_TRANSMISSION_RANGE 4

///base state the ark is created in, any state besides this will be a hostile environment
#define ARK_STATE_BASE 0
///state for the grace period after the cult has reached its member count max and have enough activing anchoring crystals to summon
#define ARK_STATE_CHARGING 1
///state for after the cult has been annouced as well as the first half of the assault
#define ARK_STATE_ACTIVE 2
///state for the halfway point of ark activation
#define ARK_STATE_SUMMONING 3
///the ark has either finished opening or been destroyed in this state
#define ARK_STATE_FINAL 4

///max damage taken per hit by "important" clock structures
#define MAX_IMPORTANT_CLOCK_DAMAGE 30
