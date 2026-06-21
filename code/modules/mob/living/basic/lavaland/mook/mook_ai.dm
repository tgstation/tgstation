///commands the chief can pick from
GLOBAL_LIST_INIT(mook_commands, list(
	new /datum/pet_command/attack,
	new /datum/pet_command/fetch,
))

/datum/ai_controller/basic_controller/mook
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/mook/mook.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_BLACKLIST_MINERAL_TURFS = list(/turf/closed/mineral/gibtonite, /turf/closed/mineral/strong),
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 7,
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	// these guys are intended to operate even if nobody's around
	ai_traits = DEFAULT_AI_FLAGS | CANNOT_GO_IDLE | CAN_RUN_WITHOUT_CLIENTS

///check for faction if not a ash walker, otherwise just attack
/datum/targeting_strategy/basic/mook/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(living_mob.has_faction(FACTION_ASHWALKER))
		return FALSE

	return ..()

///bard mook plays nice music for the village
/datum/ai_controller/basic_controller/mook/bard
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/mook/bard.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 10,
		BB_STORM_APPROACHING = FALSE,
		BB_SONG_LINES = MOOK_SONG,
	)

///healer mooks guard the village from intruders and heal the miner mooks when they come home
/datum/ai_controller/basic_controller/mook/support
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/mook/support.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_MAXIMUM_DISTANCE_TO_VILLAGE = 10,
		BB_STORM_APPROACHING = FALSE,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

///the chief would rather command his mooks to attack people than attack them himself
/datum/ai_controller/basic_controller/mook/tribal_chief
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/mook/tribal_chief.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mook,
		BB_STORM_APPROACHING = FALSE,
	)

/datum/ai_controller/basic_controller/mook/tribal_chief/New(atom/new_pawn)
	. = ..()
	set_blackboard_key(BB_MOOK_COMMANDS, GLOB.mook_commands)
