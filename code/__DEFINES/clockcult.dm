//Global vars
GLOBAL_LIST_EMPTY(all_clockwork_objects) //All clockwork items, structures, and effects in existence
GLOBAL_LIST_EMPTY(all_clockwork_mobs) //All clockwork SERVANTS (not creatures) in existence

GLOBAL_VAR_INIT(clockwork_construction_value, 0) //The total value of all structures built by the clockwork cult
GLOBAL_VAR_INIT(clockwork_potential, 0) //The amount of potential left to build with
GLOBAL_VAR_INIT(clockwork_wisdom, 25) //The cult's wisdom, which slowly regenerates and is used to fuel scripture
GLOBAL_VAR_INIT(max_clockwork_wisdom, 25) //See above

GLOBAL_VAR_INIT(city_of_cogs_beckoner, null) //The destination for all rifts to Reebe
GLOBAL_VAR_INIT(ark_of_the_clockwork_justiciar, null) //The Ark. The servants have to defend this to win.

GLOBAL_VAR_INIT(ratvar_awakens, 0) //If Ratvar has been summoned; not a boolean, for proper handling of multiple Ratvars
GLOBAL_VAR_INIT(clockwork_gateway_activated, FALSE) //if a gateway to the celestial derelict has ever been successfully activated

GLOBAL_VAR_INIT(function_scripture_unlocked, FALSE) //if function scriptures have been unlocked
GLOBAL_VAR_INIT(application_scripture_unlocked, FALSE) //if application scriptures have been unlocked
GLOBAL_LIST_EMPTY(all_scripture) //a list containing scripture instances; not used to track existing scripture


//Resource helpers
#define HAS_CLOCKWORK_POTENTIAL(amt) (GLOB.clockwork_potential >= amt)
#define ADJUST_CLOCKWORK_POTENTIAL(amt) GLOB.clockwork_potential = max(0, GLOB.clockwork_potential + amt)

#define HAS_CLOCKWORK_WISDOM(amt) (GLOB.clockwork_wisdom >= amt)
#define ADJUST_CLOCKWORK_WISDOM(amt) GLOB.clockwork_wisdom = max(0, min(GLOB.max_clockwork_wisdom, GLOB.clockwork_wisdom + amt))


//Component ID defines; these are mainly just used for spans now
#define BELLIGERENT_EYE "belligerent_eye"
#define VANGUARD_COGWHEEL "vanguard_cogwheel"
#define GEIS_CAPACITOR "geis_capacitor"
#define REPLICANT_ALLOY "replicant_alloy"
#define HIEROPHANT_ANSIBLE "hierophant_ansible"


//Scripture tiers; peripherals should never be used
#define SCRIPTURE_PERIPHERAL "Peripheral"
#define SCRIPTURE_DRIVER "Driver"
#define SCRIPTURE_SCRIPT "Script"
#define SCRIPTURE_FUNCTION "Function"
#define SCRIPTURE_APPLICATION "Application"


//Potential and wisdom defines
#define POTENTIAL_COST_SHEET 0.2 //How much potential is required for one brass sheet
#define WISDOM_COST_SHEET 1 //How much wisdom is required for one brass sheet

#define ARK_WISDOM_REGEN 5 //How many ticks the Ark needs to generate one wisdom
#define REVISION_TURBINE_WISDOM_REGEN 7 //How many ticks a revision turbine needs to generate one wisdom


//Power use defines
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


//Objective text define
#define CLOCKCULT_OBJECTIVE "Defend the Ark of the Clockwork Justicar and free Ratvar."


//Misc. defines
#define MARAUDER_EMERGE_THRESHOLD 65 //marauders cannot emerge unless host is at this% or less health

#define SIGIL_ACCESS_RANGE 2 //range at which transmission sigils can access power

#define PROSELYTIZER_REPAIR_RATE 4 //time in deciseconds between each repair operation

#define PROSELYTIZER_REPAIR_PER_TICK 10 //how much a proselytizer repairs each tick, and also how many deciseconds each tick is

#define OCULAR_WARDEN_EXCLUSION_RANGE 3 //the range at which ocular wardens cannot be placed near other ocular wardens

#define RATVARIAN_SPEAR_DURATION 1800 //how long ratvarian spears last; defaults to 3 minutes

#define PROSELYTIZER_MODE_CONVERSION "conversion" //Converting existing objects into clockwork variants, as well as repairs etc
#define PROSELYTIZER_MODE_CONSTRUCTION "construction" //Consuming potential and power to create new objects
