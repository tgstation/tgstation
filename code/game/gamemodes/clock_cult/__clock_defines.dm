var/global/clockwork_construction_value = 0 //The total value of all structures built by the clockwork cult
var/global/clockwork_caches = 0 //How many clockwork caches exist in the world (not each individual)
var/global/clockwork_daemons = 0 //How many daemons exist in the world
var/global/list/clockwork_generals_invoked = list("nezbere" = FALSE, "sevtug" = FALSE, "nzcrentr" = FALSE, "inath-neq" = FALSE) //How many generals have been recently invoked
var/global/list/all_clockwork_objects = list() //All clockwork items, structures, and effects in existence
var/global/list/all_clockwork_mobs = list() //All clockwork SERVANTS (not creatures) in existence
var/global/list/clockwork_component_cache = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0) //The pool of components that caches draw from
var/global/ratvar_awakens = FALSE //If Ratvar has been summoned

#define SCRIPTURE_PERIPHERAL 0 //Scripture tiers; peripherals should never be used
#define SCRIPTURE_DRIVER 1
#define SCRIPTURE_SCRIPT 2
#define SCRIPTURE_APPLICATION 3
#define SCRIPTURE_REVENANT 4
#define SCRIPTURE_JUDGEMENT 5

#define SLAB_PRODUCTION_TIME 400 //how long(deciseconds) slabs require to produce a single component; defaults to 40 seconds

#define CACHE_PRODUCTION_TIME 300 //how long(deciseconds) caches require to produce a component; defaults to 30 seconds

#define LOWER_PROB_PER_COMPONENT 10 //how much each component in the cache reduces the weight of getting another of that component type

#define MAX_COMPONENTS_BEFORE_RAND 10*LOWER_PROB_PER_COMPONENT //the number of each component, times LOWER_PROB_PER_COMPONENT, you need to have before component generation will become random

#define CLOCKWORK_GENERAL_COOLDOWN 3000 //how long clockwork generals go on cooldown after use, defaults to 5 minutes

//porselytizer defines
#define REPLICANT_ALLOY_UNIT 100 //how much each piece of replicant alloy gives in a clockwork proselytizer

#define REPLICANT_STANDARD REPLICANT_ALLOY_UNIT*0.2 //how much alloy is in anything else; doesn't matter as much as the following

#define REPLICANT_FLOOR REPLICANT_ALLOY_UNIT*0.1 //how much alloy is in a clockwork floor, determines the cost of clockwork floor production

#define REPLICANT_WALL_MINUS_FLOOR REPLICANT_ALLOY_UNIT*0.4 //amount of alloy in a clockwork wall, determines the cost of clockwork wall production

#define REPLICANT_WALL_TOTAL REPLICANT_WALL_MINUS_FLOOR+REPLICANT_FLOOR //how much alloy is in a clockwork wall and the floor under it

//Ark defines
#define GATEWAY_SUMMON_RATE 2 //the time amount the Gateway to the Celestial Derelict gets each process tick; defaults to 2 per tick

#define GATEWAY_REEBE_FOUND 100 //when progress is at or above this, the gateway finds reebe and begins drawing power

#define GATEWAY_RATVAR_COMING 250 //when progress is at or above this, ratvar has entered and is coming through the gateway

#define GATEWAY_RATVAR_ARRIVAL 300 //when progress is at or above this, game over ratvar's here everybody go home
