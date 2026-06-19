

/**
 * Searches for a valid beebox home. Skipped if the bee is already inside its home.
 * Sets BB_CURRENT_HOME when found.
 */
/datum/bt_node/ai_behavior/find_hive

/datum/bt_node/ai_behavior/find_hive/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bee/bee_pawn = controller.pawn
	var/obj/structure/beebox/current_home = controller.blackboard[BB_CURRENT_HOME]

	if(!QDELETED(current_home))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED // already have a home; let the inhabit sequence handle it

	if(istype(bee_pawn.loc, /obj/structure/beebox))
		controller.set_blackboard_key(BB_CURRENT_HOME, bee_pawn.loc)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	for(var/obj/structure/beebox/potential_home in oview(10, bee_pawn))
		if(!potential_home.habitable(bee_pawn))
			continue
		controller.set_blackboard_key(BB_TARGET_HOME, potential_home)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/**
 * Moves to BB_CURRENT_HOME and inhabits it (ai_interact). Clears BB_CURRENT_HOME on failure.
 * Must be in range (adjacent) to work. Returns FAILURE if home is gone or full.
 */
/datum/bt_node/ai_behavior/inhabit_hive
	time_between_perform = 10 SECONDS

/datum/bt_node/ai_behavior/inhabit_hive/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bee/bee_pawn = controller.pawn
	var/obj/structure/beebox/home = controller.blackboard[BB_CURRENT_HOME]
	if(QDELETED(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!home.habitable(bee_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!bee_pawn.Adjacent(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), home, FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/inhabit_hive/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(BB_CURRENT_HOME)

///Chance to leave or enter hive
/datum/bt_node/ai_behavior/enter_exit_hive
	time_between_perform = 1 SECONDS
	var/flyback_chance = 15
	var/exit_chance = 35

/datum/bt_node/ai_behavior/enter_exit_hive/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/structure/beebox/home = controller.blackboard[BB_CURRENT_HOME]
	if(QDELETED(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/bee_pawn = controller.pawn
	var/prob_to_use = (bee_pawn.loc == home) ? exit_chance : flyback_chance

	if(!SPT_PROB(prob_to_use, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_WANTS_TO_TRANSITION_HIVE, TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Queen variant: strongly prefers staying in hive.
/datum/bt_node/ai_behavior/enter_exit_hive/queen
	flyback_chance = 85
	exit_chance = 5


/// Pollinates the hydro tray at BB_TARGET_HYDRO. Must be adjacent.
/datum/bt_node/ai_behavior/pollinate_hydro
	time_between_perform = 5 SECONDS

/datum/bt_node/ai_behavior/pollinate_hydro/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/machinery/hydroponics/tray = controller.blackboard[BB_TARGET_HYDRO]
	var/mob/living/basic/bee/bee_pawn = controller.pawn
	if(QDELETED(tray) || !bee_pawn.Adjacent(tray))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	bee_pawn.pollinate(tray)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/pollinate_hydro/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	controller.clear_blackboard_key(BB_TARGET_HYDRO)


/// Swirls around BB_SWARM_TARGET, moving to random nearby turfs. Always returns RUNNING.
/datum/bt_node/ai_behavior/swirl_around_target
	var/swirl_chance = 60

/datum/bt_node/ai_behavior/swirl_around_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[BB_SWARM_TARGET]
	var/mob/living/bee_pawn = controller.pawn
	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(!SPT_PROB(swirl_chance, seconds_per_tick))
		return AI_BEHAVIOR_DELAY

	var/list/possible_turfs = list()
	for(var/turf/possible_turf in oview(2, target))
		if(!possible_turf.is_blocked_turf(source_atom = bee_pawn))
			possible_turfs += possible_turf

	if(length(possible_turfs))
		controller.set_movement_target(src, pick(possible_turfs))
	return AI_BEHAVIOR_DELAY


/// Scatter command: runs away from BB_CURRENT_PET_TARGET then clears the command.
/datum/bt_node/subtree/pet_command/scatter
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_scatter.bt.json"

/// Swirl command: swarm around BB_SWARM_TARGET continuously (no auto-clear).
/datum/bt_node/subtree/pet_command/swirl
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_swirl.bt.json"

/// Beehive command: move to hive and enter/exit it.
/datum/bt_node/subtree/pet_command/beehive
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_beehive.bt.json"
