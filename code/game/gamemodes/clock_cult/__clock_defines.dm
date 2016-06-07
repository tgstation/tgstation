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

#define SLAB_PRODUCTION_THRESHOLD 60 //How many cycles slabs require to produce a single component; defaults to one minute

#define GATEWAY_SUMMON_RATE 3 //The speed multiplier used by the Gateway to the Celestial Derelict; defaults to 3x speed

#define CLOCKWORK_GENERAL_COOLDOWN 3000 //how long clockwork generals go on cooldown after use, defaults to 5 minutes
