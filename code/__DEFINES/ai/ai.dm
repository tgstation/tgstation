#define GET_TARGETING_STRATEGY(targeting_type) SSai_behaviors.targeting_strategies[targeting_type]
#define GET_TARGET_PRIORITY_STRATEGY(targeting_type) SSai_behaviors.target_priority_strategies[targeting_type]
#define GET_TARGET_SOURCE(source_type) SSai_behaviors.target_sources[source_type]

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
///The AI is currently active.
#define AI_STATUS_ON "ai_on"
///The AI is currently offline for any reason.
#define AI_STATUS_OFF "ai_off"
///The AI is currently in idle mode.
#define AI_STATUS_IDLE "ai_idle"

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
/// Never pauses when off-station with no players nearby (replaces the old can_idle = FALSE)
#define CANNOT_GO_IDLE (1<<5)
/// Keeps running even when there are no clients on its z-level (replaces can_run_without_clients_on_zlevel)
#define CAN_RUN_WITHOUT_CLIENTS (1<<6)

/// Flags we expect for most AI controllers
#define DEFAULT_AI_FLAGS (PAUSE_DURING_DO_AFTER | CAN_ACT_WHILE_GRABBED)
/// Flags for passive mobs that are easy to push around
#define PASSIVE_AI_FLAGS (PAUSE_DURING_DO_AFTER | STOP_MOVING_WHEN_PULLED)

//Base Subtree defines

// DEPRECATED — porting to /datum/bt_node/subtree makes this return value unnecessary.
#define SUBTREE_RETURN_FINISH_PLANNING 1

//Generic subtree defines

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
