#define GET_TARGETING_STRATEGY(targeting_type) SSai_controllers.targeting_strategies[targeting_type]
#define GET_TARGET_PRIORITY_STRATEGY(targeting_type) SSai_controllers.target_priority_strategies[targeting_type]
#define GET_TARGET_SOURCE(source_type) SSai_controllers.target_sources[source_type]

/**
 * Returns TRUE if the target should be rejected based on factions.
 * Inlined faction check for targeting strategies but with less proc overhead.
 * Strategies with fully custom faction logic set custom_faction_check and override faction_check() instead.
 */
#define TARGETING_FACTION_CHECK(strategy, controller, living_mob, the_target) \
	(((strategy).ignore_faction || (controller).blackboard[BB_ALWAYS_IGNORE_FACTION] || (controller).blackboard[BB_TEMPORARILY_IGNORE_FACTION]) \
		? (strategy).invert_faction_check \
		: ((living_mob).faction_check_atom((the_target), exact_match = (strategy).check_factions_exactly) \
			? !(strategy).invert_faction_check \
			: (strategy).invert_faction_check))

// Revalidation modes for /datum/bt_node/ai_behavior/acquire_target
/// If a target is already set, validate it via is_valid_target before searching. Replace if invalid.
#define TARGET_REVALIDATE 1
/// If a target is already set, return SUCCESS immediately without re-checking.
#define TARGET_KEEP_IF_SET 2
/// Always run the full candidate search, ignoring any existing target.
#define TARGET_ALWAYS_SEARCH 3
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

//AI controller flags
//If you add a new status, be sure to add it to the ai_controllers subsystem's ai_controllers_by_status list.
///The AI is currently active, and is planned by the high priority subsystem.
#define AI_STATUS_ON "ai_on"
///The AI is currently active, but is planned by the low priority (background) subsystem.
#define AI_STATUS_ON_LOW "ai_on_low"
///The AI is not running. Cancels any active plans if set.
#define AI_STATUS_OFF "ai_off"

//Flags returned by get_able_to_run()
///pauses AI processing
#define AI_UNABLE_TO_RUN (1<<1)
///bypass canceling our actions on set_ai_status()
#define AI_PREVENT_CANCEL_ACTIONS (1<<2)

///For JPS pathing, the maximum length of a path we'll try to generate. Should be modularized depending on what we're doing later on
#define AI_MAX_PATH_LENGTH 30 // 30 is possibly overkill since by default we lose interest after 14 tiles of distance, but this gives wiggle room for weaving around obstacles
#define AI_BOT_PATH_LENGTH 60
#define AI_MULEBOT_PATH_LENGTH 150 //we making a pilgramage sometimes...

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


///AI flags
/// Don't move if being pulled
#define STOP_MOVING_WHEN_PULLED (1<<0)
/// Continue processing even if dead
#define CAN_ACT_WHILE_DEAD (1<<1)
/// Stop processing while in a progress bar
#define PAUSE_DURING_DO_AFTER (1<<2)
/// Continue processing while in stasis
#define CAN_ACT_IN_STASIS (1<<3)
/// Continue processing while aggressively grabbed
#define CAN_ACT_WHILE_GRABBED (1<<4)
/// Keeps planning on low prio when unwatched
#define RUN_WHILE_UNWATCHED (1<<5)
/// Always plans at high priority. Only works with RUN_WHILE_UNWATCHED
#define ALWAYS_HIGH_PRIORITY (1<<6)

/// Flags we expect for most AI controllers
#define DEFAULT_AI_FLAGS (PAUSE_DURING_DO_AFTER | CAN_ACT_WHILE_GRABBED)
/// Flags for passive mobs that are easy to push around
#define PASSIVE_AI_FLAGS (PAUSE_DURING_DO_AFTER | STOP_MOVING_WHEN_PULLED)

/// default search range (tiles, passed to oview) when using find_and_set
#define SEARCH_TACTIC_DEFAULT_RANGE 7
/// probability that the pawn should try resisting out of restraints
#define RESIST_SUBTREE_PROB 50
///macro for whether it's appropriate to resist right now, used by resist subtree
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
///macro for whether the pawn can act, used generally to prevent some horrifying ai disasters
#define IS_DEAD_OR_INCAP(source) (source.incapacitated || source.stat)

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


///Use this if you dont want a controller to show up in the sidebar (e.g. when its a class that just sets BB keys)
#define ABSTRACT_AI_CLASS "Abstract"
