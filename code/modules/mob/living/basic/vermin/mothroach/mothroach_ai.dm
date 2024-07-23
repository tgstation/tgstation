#define MOTHROACH_EAT_TIMER 1 MINUTES

/datum/ai_controller/basic_controller/mothroach
	blackboard = list(
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food/mothroach,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/mothroach,
	)

/datum/ai_controller/basic_controller/mothroach/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_MOB_ATE, PROC_REF(on_eaten))

/datum/ai_controller/basic_controller/mothroach/proc/on_eaten(datum/source)
	SIGNAL_HANDLER
	set_blackboard_key(BB_MOTHROACH_NEXT_EAT, world.time + MOTHROACH_EAT_TIMER)

/datum/ai_planning_subtree/find_food/mothroach
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/mothroach_food

/datum/ai_planning_subtree/find_food/mothroach/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(world.time < controller.blackboard[BB_MOTHROACH_NEXT_EAT])
		return
	return ..()

/datum/ai_behavior/find_and_set/in_list/mothroach_food

/datum/ai_behavior/find_and_set/in_list/mothroach_food/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	var/mob/living/living_pawn = controller.pawn
	found -= living_pawn.loc
	if(length(found))
		return pick(found)

#undef MOTHROACH_EAT_TIMER
