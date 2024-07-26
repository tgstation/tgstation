#define GET_AI_BEHAVIOR(behavior_type) SSai_behaviors.ai_behaviors[behavior_type]
#define GET_TARGETING_STRATEGY(targeting_type) SSai_behaviors.targeting_strategies[targeting_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

//AI controller flags
//If you add a new status, be sure to add it to the ai_controllers subsystem's ai_controllers_by_status list.
///The AI is currently active.
#define AI_STATUS_ON "ai_on"
///The AI is currently offline for any reason.
#define AI_STATUS_OFF "ai_off"
///The AI is currently in idle mode.
#define AI_STATUS_IDLE "ai_idle"

///For JPS pathing, the maximum length of a path we'll try to generate. Should be modularized depending on what we're doing later on
#define AI_MAX_PATH_LENGTH 30 // 30 is possibly overkill since by default we lose interest after 14 tiles of distance, but this gives wiggle room for weaving around obstacles
#define AI_BOT_PATH_LENGTH 75

// How far should we, by default, be looking for interesting things to de-idle?
#define AI_DEFAULT_INTERESTING_DIST 10

///Cooldown on planning if planning failed last time

#define AI_FAILED_PLANNING_COOLDOWN (1.5 SECONDS)

///Flags for ai_behavior new()
#define AI_CONTROLLER_INCOMPATIBLE (1<<0)

//Return flags for ai_behavior/perform()
///Update this behavior's cooldown
#define AI_BEHAVIOR_DELAY (1<<0)
///Finish the behavior successfully
#define AI_BEHAVIOR_SUCCEEDED (1<<1)
///Finish the behavior unsuccessfully
#define AI_BEHAVIOR_FAILED (1<<2)

#define AI_BEHAVIOR_INSTANT (NONE)

///Does this task require movement from the AI before it can be performed?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)
///Does this require the current_movement_target to be adjacent and in reach?
#define AI_BEHAVIOR_REQUIRE_REACH (1<<1)
///Does this task let you perform the action while you move closer? (Things like moving and shooting)
#define AI_BEHAVIOR_MOVE_AND_PERFORM (1<<2)
///Does finishing this task not null the current movement target?
#define AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH (1<<3)
///Does this behavior NOT block planning?
#define AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION (1<<4)

///AI flags
/// Don't move if being pulled
#define STOP_MOVING_WHEN_PULLED (1<<0)
/// Continue processing even if dead
#define CAN_ACT_WHILE_DEAD (1<<1)
/// Stop processing while in a progress bar
#define PAUSE_DURING_DO_AFTER (1<<2)
/// Continue processing while in stasis
#define CAN_ACT_IN_STASIS (1<<3)

//Base Subtree defines

///This subtree should cancel any further planning, (Including from other subtrees)
#define SUBTREE_RETURN_FINISH_PLANNING 1

//Generic subtree defines

/// probability that the pawn should try resisting out of restraints
#define RESIST_SUBTREE_PROB 50
///macro for whether it's appropriate to resist right now, used by resist subtree
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
///macro for whether the pawn can act, used generally to prevent some horrifying ai disasters
#define IS_DEAD_OR_INCAP(source) (source.incapacitated() || source.stat)

GLOBAL_LIST_INIT(all_radial_directions, list(
	"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
	"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHEAST),
	"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
	"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHEAST),
	"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
	"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHWEST),
	"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
	"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHWEST)
))
