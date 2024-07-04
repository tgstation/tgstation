#define SPELLTYPE_ABSTRACT "Abstract"
#define SPELLTYPE_SERVITUDE "Servitude"
#define SPELLTYPE_PRESERVATION "Preservation"
#define SPELLTYPE_STRUCTURES "Structures"

#define SIGIL_TRANSMISSION_RANGE 4

#define MAX_CLOCK_VITALITY 400

///base state the ark is created in, any state besides this will be a hostile environment
#define ARK_STATE_BASE 0
///state for the grace period after the cult has reached its member count max and have enough activing anchoring crystals to summon
#define ARK_STATE_CHARGING 1
///state for after the cult has been annouced and are preparing for the portals to open
#define ARK_STATE_GRACE 2
///state for the first half of the assault
#define ARK_STATE_ACTIVE 3
///state for the halfway point of ark activation
#define ARK_STATE_SUMMONING 4
///the ark has either finished opening or been destroyed in this state
#define ARK_STATE_FINAL 5

///max damage taken per hit by "important" clock structures
#define MAX_IMPORTANT_CLOCK_DAMAGE 30

///how many anchoring crystals need to be active before the ark can open
#define ANCHORING_CRYSTALS_TO_SUMMON 2

///the map path of the reebe map
#define REEBE_MAP_PATH "_maps/~monkestation/templates/reebe.dmm"

///how long between uses of the anchoring crystal scripture, also how long the hostile environment lasts if the crystal is not destroyed
#define ANCHORING_CRYSTAL_COOLDOWN 7 MINUTES

///up to how many tiles away will the ark stop certain things from breaking turfs
#define ARK_TURF_DESTRUCTION_BLOCK_RANGE 9
