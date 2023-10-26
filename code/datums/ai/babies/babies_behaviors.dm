/**
 * Find a compatible, living partner, if we're also alone.
 */
/datum/ai_behavior/find_partner
	action_cooldown = 40 SECONDS

	/// Range to look.
	var/range = 7

	/// Maximum number of children
	var/max_children = 3

/datum/ai_behavior/find_partner/perform(seconds_per_tick, datum/ai_controller/controller, target_key, partner_types_key, child_types_key)
	. = ..()

	var/mob/pawn_mob = controller.pawn
	var/list/partner_types = controller.blackboard[partner_types_key]
	var/list/child_types = controller.blackboard[child_types_key]

	var/mob/living/partner
	var/children = 0
	for(var/mob/other in oview(range, pawn_mob))
		if(other.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue
		var/is_child = is_type_in_list(other, child_types)
		if(is_child) //Check for children SECOND.
			children++
		else if(is_type_in_list(other, partner_types))
			if(other.ckey)
				continue
			else if(!is_child && other.gender == MALE && !(other.flags_1 & HOLOGRAM_1)) //Better safe than sorry ;_;
				partner = other

		//shyness check. we're not shy in front of things that share a faction with us.
		else if(isliving(other) && !pawn_mob.faction_check_atom(other))
			finish_action(controller, FALSE)
			return

	if(partner && children < max_children)
		controller.set_blackboard_key(target_key, partner)

	finish_action(controller, TRUE)

/**
 * Reproduce.
 */
/datum/ai_behavior/make_babies
	action_cooldown = 40 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/make_babies/setup(datum/ai_controller/controller, target_key, child_types_key)
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE
	set_movement_target(controller, target)
	return TRUE

/datum/ai_behavior/make_babies/perform(seconds_per_tick, datum/ai_controller/controller, target_key, child_types_key)
	. = ..()
	var/mob/target = controller.blackboard[target_key]
	if(!target || target.stat != CONSCIOUS)
		finish_action(controller, FALSE, target_key)
		return

	var/child_type = pick_weight(controller.blackboard[child_types_key])
	var/turf/turf_loc = get_turf(controller.pawn.loc)
	if(turf_loc)
		new child_type(turf_loc)

	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/make_babies/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()

	controller.clear_blackboard_key(target_key)
