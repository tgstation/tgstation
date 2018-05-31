//component id defines; sometimes these may not make sense in regards to their use in scripture but important ones are bright
#define BELLIGERENT_EYE "belligerent_eye" //Use this for offensive and damaging scripture!
#define VANGUARD_COGWHEEL "vanguard_cogwheel" //Use this for defensive and healing scripture!
#define GEIS_CAPACITOR "geis_capacitor" //Use this for niche scripture!
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible" //Use this for construction-related scripture!

GLOBAL_VAR_INIT(clockwork_construction_value, 0) //The total value of all structures built by the clockwork cult
GLOBAL_VAR_INIT(clockwork_vitality, 0) //How much Vitality is stored, total
GLOBAL_VAR_INIT(clockwork_power, 0) //How many watts of power are globally available to the clockwork cult

GLOBAL_LIST_EMPTY(all_clockwork_objects) //All clockwork items, structures, and effects in existence
GLOBAL_LIST_EMPTY(all_clockwork_mobs) //All clockwork SERVANTS (not creatures) in existence

GLOBAL_VAR_INIT(ratvar_approaches, 0) //The servants can choose to "herald" Ratvar, permanently buffing them but announcing their presence to the crew.
GLOBAL_VAR_INIT(ratvar_awakens, 0) //If Ratvar has been summoned; not a boolean, for proper handling of multiple Ratvars
GLOBAL_VAR_INIT(ark_of_the_clockwork_justiciar, FALSE) //The Ark on the Reebe z-level

GLOBAL_VAR_INIT(clockwork_gateway_activated, FALSE) //if a gateway to the celestial derelict has ever been successfully activated
GLOBAL_VAR_INIT(script_scripture_unlocked, FALSE) //If script scripture is available, through converting at least one crewmember
GLOBAL_VAR_INIT(application_scripture_unlocked, FALSE) //If script scripture is available
GLOBAL_LIST_EMPTY(all_scripture) //a list containing scripture instances; not used to track existing scripture

//Scripture tiers and requirements; peripherals should never be used
#define SCRIPTURE_PERIPHERAL "Peripheral"
#define SCRIPTURE_DRIVER "Driver"
#define SCRIPTURE_SCRIPT "Script"
#define SCRIPTURE_APPLICATION "Application"

//Various costs related to power.
#define MAX_CLOCKWORK_POWER 50000 //The max power in W that the cult can stockpile
#define SCRIPT_UNLOCK_THRESHOLD 25000 //Scripts will unlock if the total power reaches this amount
#define APPLICATION_UNLOCK_THRESHOLD 40000 //Applications will unlock if the total powre reaches this amount

#define ABSCOND_ABDUCTION_COST 95

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

//Ark defines
#define GATEWAY_SUMMON_RATE 1 //the time amount the Gateway to the Celestial Derelict gets each process tick; defaults to 1 per tick

#define GATEWAY_REEBE_FOUND 240 //when progress is at or above this, the gateway finds reebe and begins drawing power

#define GATEWAY_RATVAR_COMING 480 //when progress is at or above this, ratvar has entered and is coming through the gateway

#define GATEWAY_RATVAR_ARRIVAL 600 //when progress is at or above this, game over ratvar's here everybody go home

//Objective text define
#define CLOCKCULT_OBJECTIVE "Construct the Ark of the Clockwork Justicar and free Ratvar."

//Eminence defines
#define SUPERHEATED_CLOCKWORK_WALL_LIMIT 20 //How many walls can be superheated at once

//misc clockcult stuff

#define SIGIL_ACCESS_RANGE 2 //range at which transmission sigils can access power

#define FABRICATOR_REPAIR_PER_TICK 4 //how much a fabricator repairs each tick, and also how many deciseconds each tick is

#define OCULAR_WARDEN_EXCLUSION_RANGE 3 //the range at which ocular wardens cannot be placed near other ocular wardens

#define CLOCKWORK_ARMOR_COOLDOWN 1800 //The cooldown period between summoning suits of clockwork armor

#define RATVARIAN_SPEAR_COOLDOWN 300 //The cooldown period between summoning another Ratvarian spear

#define MARAUDER_SCRIPTURE_SCALING_THRESHOLD 600 //The amount of deciseconds that must pass before marauder scripture will not gain a recital penalty

#define MARAUDER_SCRIPTURE_SCALING_TIME 20 //The amount of extra deciseconds tacked on to the marauder scripture recital time per recent marauder

#define MARAUDER_SCRIPTURE_SCALING_MAX 300 //The maximum extra time applied to the marauder scripture

#define ARK_SCREAM_COOLDOWN 600 //This much time has to pass between instances of the Ark taking damage before it will "scream" again
