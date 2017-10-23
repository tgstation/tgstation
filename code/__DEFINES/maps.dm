/*
The /tg/ codebase currently requires you to have 11 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside the map config.dm will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of October 23, 2017
z1 = centcom
z2 = mining
z3-x = station
Everything else = Handled by mapping subsystem
*/

#define CROSSLINKED 2
#define SELFLOOPING 1
#define UNAFFECTED 0

// Attributes (In text for the convenience of those using VV)
#define BLOCK_TELEPORT "Blocks Teleport"
// Impedes with the casting of some spells
#define IMPEDES_MAGIC "Impedes Magic"
// A level the station exists on
#define STATION_LEVEL "Station Level"
// A level affected by Code Red announcements, cargo telepads, or similar
#define STATION_CONTACT "Station Contact"
// A level dedicated to admin use
#define ADMIN_LEVEL "Admin Level"
// For away missions - used by some consoles
#define AWAY_LEVEL "Away"
// Enhances telecomms signals
#define BOOSTS_SIGNAL "Boosts signals"
// Currently used for determining mining score
#define ORE_LEVEL "Mining"
// Levels the AI can control bots on
#define AI_OK "AI Allowed"

//for modifying jobs
#define MAP_JOB_CHECK if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return; }
#define MAP_JOB_CHECK_BASE if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return ..(); }
#define MAP_REMOVE_JOB(jobpath) /datum/job/##jobpath/map_check() { return (SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) && ..() }

#define SPACERUIN_MAP_EDGE_PAD 15

#define DL_NAME "name"
#define DL_LINKAGE "linkage"
#define DL_ATTRS "attributes"

#define DECLARE_LEVEL(NAME,LINKS,TRAITS) list(DL_NAME = NAME, DL_LINKAGE = LINKS, DL_ATTRS = TRAITS)

#define DEFAULT_MAP_TRAITS list(\
DECLARE_LEVEL("Centcom", SELFLOOPING, list(ADMIN_LEVEL = TRUE, BLOCK_TELEPORT = TRUE, IMPEDES_MAGIC = TRUE)),\
DECLARE_LEVEL("Mining Asteroid", UNAFFECTED, list(STATION_LEVEL = TRUE, STATION_CONTACT = TRUE, AI_OK = TRUE, ORE_LEVEL = TRUE)),\
DECLARE_LEVEL("Main Station", CROSSLINKED, list(STATION_LEVEL = TRUE, STATION_CONTACT = TRUE, AI_OK = TRUE)),\
))