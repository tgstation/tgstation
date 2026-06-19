
///hey buddy I went to mook village and everyone there knew you
/datum/bt_node/ai_behavior/find_village
	/// Blackboard key to store the found landmark.
	var/target_key = BB_HOME_VILLAGE

/datum/bt_node/ai_behavior/find_village/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/effect/landmark/home = locate(/obj/effect/landmark/mook_village) in GLOB.landmarks_list
	if(isnull(home))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, home)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Mook-specific mineral wall finder that skips turfs in BB_BLACKLIST_MINERAL_TURFS.
/datum/bt_node/ai_behavior/find_mineral_wall/mook

/datum/bt_node/ai_behavior/find_mineral_wall/mook/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	if(is_type_in_list(target_wall, forbidden))
		return FALSE
	return ..()

///find the chief. why we dont do this in the basic mob? dont ask me.
/datum/bt_node/ai_behavior/find_and_set/find_chief

/datum/bt_node/ai_behavior/find_and_set/find_chief/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	return locate(/mob/living/basic/mining/mook/worker/tribal_chief) in oview(search_range, controller.pawn)

///Wander in a random direction to find ore
/datum/bt_node/ai_behavior/calculate_wander_destination
	/// Blackboard key holding the anchor atom to wander away from.
	var/anchor_key = BB_HOME_VILLAGE/// Blackboard key to write the chosen turf into.
	var/destination_key = BB_WANDER_DESTINATION
	/// How far we try to wander from the anchor.
	var/wander_distance = 9

/datum/bt_node/ai_behavior/calculate_wander_destination/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/atom/anchor = controller.blackboard[anchor_key]
	if(QDELETED(anchor))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(anchor.z != living_pawn.z)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/angle_directions = list()
	for(var/direction in GLOB.alldirs)
		angle_directions += dir2angle(direction)

	var/angle_to_home = get_angle(living_pawn, anchor)
	angle_directions -= angle_to_home
	angle_directions -= (angle_to_home + 45)
	angle_directions -= (angle_to_home - 45)
	shuffle_inplace(angle_directions)

	var/turf/best = get_turf(living_pawn)
	for(var/angle in angle_directions)
		var/turf/candidate = _get_furthest_turf(living_pawn, angle, anchor)
		if(isnull(candidate))
			continue
		var/dist = get_dist(anchor, candidate)
		if(dist <= get_dist(anchor, best))
			continue
		best = candidate
		if(dist >= wander_distance)
			break

	controller.set_blackboard_key(destination_key, best)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/calculate_wander_destination/proc/_get_furthest_turf(atom/source, angle, atom/anchor)
	var/turf/result
	for(var/i in 1 to wander_distance)
		var/turf/candidate = get_ranged_target_turf_direct(source, anchor, range = i, offset = angle)
		if(candidate.is_blocked_turf(source_atom = source))
			break
		result = candidate
	return result


///gotta get south of the material stand
/datum/bt_node/ai_behavior/find_deposit_position
	/// Blackboard key holding the /obj/structure/ore_container/material_stand target.
	var/stand_key = BB_MATERIAL_STAND_TARGET
	/// Blackboard key to write the chosen deposit turf into.
	var/destination_key = BB_DEPOSIT_POSITION

/datum/bt_node/ai_behavior/find_deposit_position/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/stand = controller.blackboard[stand_key]
	if(QDELETED(stand))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/pawn = controller.pawn
	var/list/candidates = list()
	for(var/direction in list(SOUTH, SOUTHWEST, SOUTHEAST))
		var/turf/candidate = get_step(stand, direction)
		if(!candidate.is_blocked_turf())
			candidates += candidate
	var/turf/destination = get_closest_atom(/turf/, candidates, pawn)
	if(isnull(destination))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(destination_key, destination)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

///OH SHIT STORM COMING (or maybe we found ore :3)
/datum/bt_node/decorator/mook_has_flee_reason

/datum/bt_node/decorator/mook_has_flee_reason/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(\
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_STORM_APPROACHING),\
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_SIMPLE_CARRY_ITEM),\
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_SIMPLE_CARRY_ITEM),\
	), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/mook_has_flee_reason/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(\
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_STORM_APPROACHING),\
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_SIMPLE_CARRY_ITEM),\
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_SIMPLE_CARRY_ITEM),\
	))

/datum/bt_node/decorator/mook_has_flee_reason/check_condition(datum/ai_controller/controller)
	return controller.blackboard[BB_STORM_APPROACHING] || !isnull(controller.blackboard[BB_SIMPLE_CARRY_ITEM])



/datum/bt_node/subtree/generic_mook_behavior
	behavior_tree_json = "generic_mook_behavior.bt.json"


///Worker trees
/datum/bt_node/subtree/worker_find_targets
	behavior_tree_json = "worker_find_targets.bt.json"

/datum/bt_node/subtree/go_mining
	behavior_tree_json = "go_mining.bt.json"


///Bard trees
/datum/bt_node/subtree/bard_play_music
	behavior_tree_json = "bard_play_music.bt.json"

/datum/bt_node/subtree/bard_find_targets
	behavior_tree_json = "bard_find_targets.bt.json"


///Support trees
/datum/bt_node/subtree/heal_injured
	behavior_tree_json = "heal_injured.bt.json"

/datum/bt_node/subtree/support_find_targets
	behavior_tree_json = "support_find_targets.bt.json"

///Chief trees
/datum/bt_node/subtree/chief_issue_commands
	behavior_tree_json = "chief_issue_commands.bt.json"

/datum/bt_node/subtree/chief_manage_village
	behavior_tree_json = "chief_manage_village.bt.json"


/datum/bt_node/subtree/chief_find_targets
	behavior_tree_json = "chief_find_targets.bt.json"
