//component id defines
#define BELLIGERENT_EYE "belligerent_eye"
#define VANGUARD_COGWHEEL "vanguard_cogwheel"
#define GEIS_CAPACITOR "geis_capacitor"
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible"

GLOBAL_VAR_INIT(clockwork_construction_value, 0) //The total value of all structures built by the clockwork cult
GLOBAL_VAR_INIT(clockwork_caches, 0) //How many clockwork caches exist in the world (not each individual)
GLOBAL_VAR_INIT(clockwork_daemons, 0) //How many daemons exist in the world
GLOBAL_LIST_INIT(clockwork_generals_invoked, list("nezbere" = FALSE, "sevtug" = FALSE, "nzcrentr" = FALSE, "inath-neq" = FALSE)) //How many generals have been recently invoked
GLOBAL_LIST_EMPTY(all_clockwork_objects) //All clockwork items, structures, and effects in existence
GLOBAL_LIST_EMPTY(all_clockwork_mobs) //All clockwork SERVANTS (not creatures) in existence
GLOBAL_LIST_INIT(clockwork_component_cache, list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)) //The pool of components that caches draw from
GLOBAL_VAR_INIT(ratvar_awakens, 0) //If Ratvar has been summoned; not a boolean, for proper handling of multiple Ratvars
GLOBAL_VAR_INIT(nezbere_invoked, 0) //If Nezbere has been invoked; not a boolean, for proper handling of multiple Nezberes
GLOBAL_VAR_INIT(clockwork_gateway_activated, FALSE) //if a gateway to the celestial derelict has ever been successfully activated
GLOBAL_LIST_EMPTY(all_scripture) //a list containing scripture instances; not used to track existing scripture

//Scripture tiers and requirements; peripherals should never be used
#define SCRIPTURE_PERIPHERAL "Peripheral"
#define SCRIPTURE_DRIVER "Driver"
#define SCRIPTURE_SCRIPT "Script"
#define SCRIPT_SERVANT_REQ 5
#define SCRIPT_CACHE_REQ 1
#define SCRIPTURE_APPLICATION "Application"
#define APPLICATION_SERVANT_REQ 8
#define APPLICATION_CACHE_REQ 3
#define APPLICATION_CV_REQ 100
#define SCRIPTURE_REVENANT "Revenant"
#define REVENANT_SERVANT_REQ 10
#define REVENANT_CACHE_REQ 4
#define REVENANT_CV_REQ 200
#define SCRIPTURE_JUDGEMENT "Judgement"
#define JUDGEMENT_SERVANT_REQ 12
#define JUDGEMENT_CACHE_REQ 5
#define JUDGEMENT_CV_REQ 300

//general component/cooldown things
#define SLAB_PRODUCTION_TIME 450 //how long(deciseconds) slabs require to produce a single component; defaults to 45 seconds

#define SLAB_SERVANT_SLOWDOWN 150 //how much each servant above 5 slows down slab-based generation; defaults to 15 seconds per sevant

#define SLAB_SLOWDOWN_MAXIMUM 1350 //maximum slowdown from additional servants; defaults to 2 minutes 15 seconds

#define CACHE_PRODUCTION_TIME 300 //how long(deciseconds) caches require to produce a component; defaults to 30 seconds

#define ACTIVE_CACHE_SLOWDOWN 50 //how many additional deciseconds caches take to produce a component for each linked cache; defaults to 5 seconds

#define LOWER_PROB_PER_COMPONENT 10 //how much each component in the cache reduces the weight of getting another of that component type

#define MAX_COMPONENTS_BEFORE_RAND (10*LOWER_PROB_PER_COMPONENT) //the number of each component, times LOWER_PROB_PER_COMPONENT, you need to have before component generation will become random

#define GLOBAL_CLOCKWORK_GENERAL_COOLDOWN 3000 //how long globally-affecting clockwork generals go on cooldown after use, defaults to 5 minutes

#define CLOCKWORK_GENERAL_COOLDOWN 2000 //how long clockwork generals go on cooldown after use, defaults to 3 minutes 20 seconds

//clockcult power defines
#define MIN_CLOCKCULT_POWER 25 //the minimum amount of power clockcult machines will handle gracefully

#define CLOCKCULT_POWER_UNIT (MIN_CLOCKCULT_POWER*100) //standard power amount for clockwork proselytizer costs

#define POWER_STANDARD (CLOCKCULT_POWER_UNIT*0.2) //how much power is in anything else; doesn't matter as much as the following

#define POWER_FLOOR (CLOCKCULT_POWER_UNIT*0.1) //how much power is in a clockwork floor, determines the cost of clockwork floor production

#define POWER_WALL_MINUS_FLOOR (CLOCKCULT_POWER_UNIT*0.4) //how much power is in a clockwork wall, determines the cost of clockwork wall production

#define POWER_GEAR (CLOCKCULT_POWER_UNIT*0.3) //how much power is in a wall gear, minus the brass from the wall

#define POWER_WALL_TOTAL (POWER_WALL_MINUS_FLOOR+POWER_FLOOR) //how much power is in a clockwork wall and the floor under it

#define POWER_ROD (CLOCKCULT_POWER_UNIT*0.01) //how much power is in one rod

#define POWER_METAL (CLOCKCULT_POWER_UNIT*0.02) //how much power is in one sheet of metal

#define POWER_PLASTEEL (CLOCKCULT_POWER_UNIT*0.05) //how much power is in one sheet of plasteel

#define RATVAR_POWER_CHECK "ratvar?" //when passed into can_use_power(), converts it into a check for if ratvar has woken/the proselytizer is debug

//Ark defines
#define GATEWAY_SUMMON_RATE 1 //the time amount the Gateway to the Celestial Derelict gets each process tick; defaults to 1 per tick

#define GATEWAY_REEBE_FOUND 119 //when progress is at or above this, the gateway finds reebe and begins drawing power

#define GATEWAY_RATVAR_COMING 239 //when progress is at or above this, ratvar has entered and is coming through the gateway

#define GATEWAY_RATVAR_ARRIVAL 300 //when progress is at or above this, game over ratvar's here everybody go home

#define ARK_SUMMON_COST 5 //how many of each component an Ark costs to summon

#define ARK_CONSUME_COST 15 //how many of each component an Ark needs to consume to activate

//Objective text define
#define CLOCKCULT_OBJECTIVE "Construct the Ark of the Clockwork Justicar and free Ratvar."

//misc clockcult stuff
#define MARAUDER_EMERGE_THRESHOLD 65 //marauders cannot emerge unless host is at this% or less health

#define SIGIL_ACCESS_RANGE 2 //range at which transmission sigils can access power

#define PROSELYTIZER_REPAIR_PER_TICK 4 //how much a proselytizer repairs each tick, and also how many deciseconds each tick is

#define OCULAR_WARDEN_EXCLUSION_RANGE 3 //the range at which ocular wardens cannot be placed near other ocular wardens

#define RATVARIAN_SPEAR_DURATION 1800 //how long ratvarian spears last; defaults to 3 minutes
