//component id defines
#define BELLIGERENT_EYE "belligerent_eye"
#define VANGUARD_COGWHEEL "vanguard_cogwheel"
#define GEIS_CAPACITOR "geis_capacitor"
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible"

GLOBAL_VAR_INIT(clockwork_construction_value, 0) //The total value of all structures built by the clockwork cult
GLOBAL_VAR_INIT(clockwork_vitality, 0) //How much Vitality is stored, total
GLOBAL_VAR_INIT(clockwork_power, 0) //How much Power is stored, total
GLOBAL_LIST_EMPTY(active_daemons) //A list of all active tinkerer's daemons
GLOBAL_LIST_EMPTY(all_clockwork_objects) //All clockwork items, structures, and effects in existence
GLOBAL_LIST_EMPTY(all_clockwork_mobs) //All clockwork SERVANTS (not creatures) in existence
GLOBAL_LIST_INIT(clockwork_component_cache, list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)) //The pool of components that caches draw from
GLOBAL_VAR_INIT(ratvar_awakens, 0) //If Ratvar has been summoned; not a boolean, for proper handling of multiple Ratvars
GLOBAL_DATUM(ark_of_the_clockwork_justicar, /obj/structure/destructible/clockwork/massive/celestial_gateway)
GLOBAL_VAR_INIT(initial_ark_time, 0) //In deciseonds, the initial time before the ark activates
GLOBAL_VAR_INIT(herald_votes, 0) //how many yes votes have been cast for heralding the ark
GLOBAL_VAR_INIT(herald_vote_complete, FALSE) //if the vote has finishes
GLOBAL_VAR_INIT(ark_heralded, FALSE) //if the servants have given up stealth for bonuses
GLOBAL_VAR_INIT(clockwork_gateway_activated, FALSE) //if a gateway to the celestial derelict has ever been successfully activated
GLOBAL_LIST_EMPTY(all_scripture) //a list containing scripture instances; not used to track existing scripture

//Scripture tiers and requirements; peripherals should never be used
#define SCRIPTURE_PERIPHERAL "Peripheral"
#define SCRIPTURE_DRIVER "Driver"
#define SCRIPTURE_SCRIPT "Script"

//general component/cooldown things
#define SLAB_PRODUCTION_TIME 900 //how long(deciseconds) slabs require to produce a single component; defaults to 90 seconds

#define CACHE_PRODUCTION_TIME 100 //how long(deciseconds) caches require to produce a component; defaults to 10 seconds

#define ACTIVE_CACHE_SLOWDOWN 100 //how many additional deciseconds caches take to produce a component for each linked cache; defaults to 10 seconds

#define LOWER_PROB_PER_COMPONENT 10 //how much each component in the cache reduces the weight of getting another of that component type

#define MAX_COMPONENTS_BEFORE_RAND (10*LOWER_PROB_PER_COMPONENT) //the number of each component, times LOWER_PROB_PER_COMPONENT, you need to have before component generation will become random

//clockcult power defines
#define MIN_CLOCKCULT_POWER 25 //the minimum amount of power clockcult machines will handle gracefully

#define CLOCKCULT_POWER_UNIT (MIN_CLOCKCULT_POWER*100) //standard power amount for replica fabricator costs

#define POWER_STANDARD (CLOCKCULT_POWER_UNIT*0.2) //how much power is in anything else; doesn't matter as much as the following

#define POWER_FLOOR (CLOCKCULT_POWER_UNIT*0.1) //how much power is in a clockwork floor, determines the cost of clockwork floor production

#define POWER_WALL_MINUS_FLOOR (CLOCKCULT_POWER_UNIT*0.4) //how much power is in a clockwork wall, determines the cost of clockwork wall production

#define POWER_GEAR (CLOCKCULT_POWER_UNIT*0.3) //how much power is in a wall gear, minus the brass from the wall

#define POWER_WALL_TOTAL (POWER_WALL_MINUS_FLOOR+POWER_FLOOR) //how much power is in a clockwork wall and the floor under it

#define POWER_ROD (CLOCKCULT_POWER_UNIT*0.01) //how much power is in one rod

#define POWER_METAL (CLOCKCULT_POWER_UNIT*0.02) //how much power is in one sheet of metal

#define POWER_PLASTEEL (CLOCKCULT_POWER_UNIT*0.05) //how much power is in one sheet of plasteel

#define RATVAR_POWER_CHECK "ratvar?" //when passed into can_use_power(), converts it into a check for if ratvar has woken/the fabricator is debug

//Ark defines
#define GATEWAY_SUMMON_RATE 1 //the time amount the Gateway to the Celestial Derelict gets each process tick; defaults to 1 per tick

#define GATEWAY_REEBE_FOUND 239 //when progress is at or above this, the gateway finds reebe and begins drawing power

#define GATEWAY_RATVAR_COMING 479 //when progress is at or above this, ratvar has entered and is coming through the gateway

#define GATEWAY_RATVAR_ARRIVAL 600 //when progress is at or above this, game over ratvar's here everybody go home

#define ARK_SUMMON_COST 5 //how many of each component an Ark costs to summon

//Objective text define
#define CLOCKCULT_OBJECTIVE "Construct the Ark of the Clockwork Justicar and free Ratvar."

//misc clockcult stuff
#define MARAUDER_EMERGE_THRESHOLD 65 //marauders cannot emerge unless host is at this% or less health

#define FABRICATOR_REPAIR_PER_TICK 4 //how much a fabricator repairs each tick, and also how many deciseconds each tick is

#define OCULAR_WARDEN_EXCLUSION_RANGE 3 //the range at which ocular wardens cannot be placed near other ocular wardens

#define RATVARIAN_SPEAR_DURATION 1800 //how long ratvarian spears last; defaults to 3 minutes

#define PRISM_DELAY_DURATION 1200 //how long prolonging prisms delay the shuttle for; defaults to 2 minutes
