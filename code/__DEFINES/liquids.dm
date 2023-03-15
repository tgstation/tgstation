#define WATER_HEIGH_DIFFERENCE_SOUND_CHANCE 50
#define WATER_HEIGH_DIFFERENCE_DELTA_SPLASH 7 //Delta needed for the splash effect to be made in 1 go

#define REQUIRED_EVAPORATION_PROCESSES 40
#define EVAPORATION_CHANCE 10

#define REQUIRED_FIRE_PROCESSES 2
#define REQUIRED_FIRE_POWER_PER_UNIT 5
#define FIRE_BURN_PERCENT 10

#define REQUIRED_OCEAN_PROCESSES 5

#define PARTIAL_TRANSFER_AMOUNT 0.3

#define LIQUID_MUTUAL_SHARE 1
#define LIQUID_NOT_MUTUAL_SHARE 2

#define LIQUID_GIVER 1
#define LIQUID_TAKER 2

//Required amount of a reagent to be simulated on turf exposures from liquids (to prevent gaming the system with cheap dillutions)
#define LIQUID_REAGENT_THRESHOLD_TURF_EXPOSURE 5

//Threshold at which the difference of height makes us need to climb/blocks movement/allows to fall down
#define TURF_HEIGHT_BLOCK_THRESHOLD 20

#define LIQUID_HEIGHT_DIVISOR 10

#define ONE_LIQUIDS_HEIGHT LIQUID_HEIGHT_DIVISOR

#define LIQUID_ATTRITION_TO_STOP_ACTIVITY 2

//Percieved heat capacity for calculations with atmos sharing
#define REAGENT_HEAT_CAPACITY		5

#define LIQUID_STATE_PUDDLE			1
#define LIQUID_STATE_ANKLES			2
#define LIQUID_STATE_WAIST			3
#define LIQUID_STATE_SHOULDERS		4
#define LIQUID_STATE_FULLTILE		5
#define TOTAL_LIQUID_STATES			5
#define LYING_DOWN_SUBMERGEMENT_STATE_BONUS			2

#define LIQUID_STATE_FOR_HEAT_EXCHANGERS LIQUID_STATE_WAIST

#define LIQUID_ANKLES_LEVEL_HEIGHT 8
#define LIQUID_WAIST_LEVEL_HEIGHT 19
#define LIQUID_SHOULDERS_LEVEL_HEIGHT 29
#define LIQUID_FULLTILE_LEVEL_HEIGHT 39

#define LIQUID_FIRE_STATE_NONE		0
#define LIQUID_FIRE_STATE_SMALL		1
#define LIQUID_FIRE_STATE_MILD		2
#define LIQUID_FIRE_STATE_MEDIUM	3
#define LIQUID_FIRE_STATE_HUGE		4
#define LIQUID_FIRE_STATE_INFERNO	5

//Threshold at which we "choke" on the water, instead of holding our breath
#define OXYGEN_DAMAGE_CHOKING_THRESHOLD 15

#define IMMUTABLE_LIQUID_SHARE 1

#define LIQUID_RECURSIVE_LOOP_SAFETY 255

//Height at which we consider the tile "full" and dont drop liquids on it from the upper Z level
#define LIQUID_HEIGHT_CONSIDER_FULL_TILE 50

#define LIQUID_GROUP_DECAY_TIME 3

//Scaled with how much a person is submerged
#define SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT 60

#define CHOKE_REAGENTS_INGEST_ON_FALL_AMOUNT 4

#define CHOKE_REAGENTS_INGEST_ON_BREATH_AMOUNT 2

#define SUBMERGEMENT_PERCENT(carbon, liquids) min(1,(!MOBILITY_STAND ? liquids.liquid_group.group_overlay_state+LYING_DOWN_SUBMERGEMENT_STATE_BONUS : liquids.liquid_group.group_overlay_state)/TOTAL_LIQUID_STATES)

GLOBAL_LIST_INIT(liquid_blacklist, list(
	/datum/reagent/sorium,
	/datum/reagent/liquid_dark_matter
))
