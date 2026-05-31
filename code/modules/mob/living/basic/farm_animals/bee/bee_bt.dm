// =============================================================================
// Bee BT-native behaviors
// =============================================================================

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
		controller.set_blackboard_key(BB_CURRENT_HOME, potential_home)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================

/**
 * Moves to BB_CURRENT_HOME and inhabits it (ai_interact). Clears BB_CURRENT_HOME on failure.
 * Must be in range (adjacent) to work. Returns FAILURE if home is gone or full.
 */
/datum/bt_node/ai_behavior/inhabit_hive
	action_cooldown = 10 SECONDS

/datum/bt_node/ai_behavior/inhabit_hive/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bee/bee_pawn = controller.pawn
	var/obj/structure/beebox/home = controller.blackboard[BB_CURRENT_HOME]
	if(QDELETED(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!home.habitable(bee_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!bee_pawn.Adjacent(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = home, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/inhabit_hive/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(BB_CURRENT_HOME)

// =============================================================================

/**
 * Probabilistically enters or exits the beehive.
 * If inside hive → rolls exit_chance% to leave.
 * If outside → rolls flyback_chance% to return home.
 * Returns FAILURE when not rolling so the selector passes through.
 */
/datum/bt_node/ai_behavior/enter_exit_hive
	action_cooldown = 10 SECONDS
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

	if(!bee_pawn.Adjacent(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	controller.ai_interact(target = home, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Queen variant: strongly prefers staying in hive.
/datum/bt_node/ai_behavior/enter_exit_hive/queen
	flyback_chance = 85
	exit_chance = 5

// =============================================================================

/// Finds a hydroponics tray that can be pollinated. Sets BB_TARGET_HYDRO.
/datum/bt_node/ai_behavior/find_pollination_target
	action_cooldown = 10 SECONDS

/datum/bt_node/ai_behavior/find_pollination_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/bee_pawn = controller.pawn
	if(!isturf(bee_pawn.loc))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!SPT_PROB(85, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/obj/machinery/hydroponics/tray in oview(10, bee_pawn))
		if(!tray.can_bee_pollinate())
			continue
		if(!can_see(bee_pawn, tray, 10))
			continue
		controller.set_blackboard_key(BB_TARGET_HYDRO, tray)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================

/// Pollinates the hydro tray at BB_TARGET_HYDRO. Must be adjacent.
/datum/bt_node/ai_behavior/pollinate_hydro
	action_cooldown = 5 SECONDS

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

// =============================================================================

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

// =============================================================================

/// Scatter command: runs away from BB_CURRENT_PET_TARGET then clears the command.
/datum/bt_node/subtree/pet_command/scatter
	behavior_tree_json = "pet_command_scatter.bt.json"

/// Swirl command: swarm around BB_SWARM_TARGET continuously (no auto-clear).
/datum/bt_node/subtree/pet_command/swirl
	behavior_tree_json = "pet_command_swirl.bt.json"

/// Beehive command: move to hive and enter/exit it.
/datum/bt_node/subtree/pet_command/beehive
	behavior_tree_json = "pet_command_beehive.bt.json"
