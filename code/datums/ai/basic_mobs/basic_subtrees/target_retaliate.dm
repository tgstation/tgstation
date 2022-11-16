/// Sets the BB target to a mob which you can see and who has recently attacked you
/datum/ai_planning_subtree/target_retaliate

/datum/ai_planning_subtree/target_retaliate/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list, BB_BASIC_MOB_RETALIATE_LIST, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/**
 * Picks a target from a provided list of atoms who have been pissing you off
 * You will probably need /datum/element/ai_retaliate to take advantage of this unless you're populating the blackboard yourself
 */
/datum/ai_behavior/target_from_retaliate_list
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9

/datum/ai_behavior/target_from_retaliate_list/perform(delta_time, datum/ai_controller/controller, shitlist_key, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/living_mob = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/list/enemy_refs = controller.blackboard[shitlist_key]
	if (!length(enemy_refs))
		finish_action(controller, FALSE)
		return

	var/list/enemies_list = list()
	for (var/datum/weakref/enemy_ref as anything in enemy_refs)
		var/atom/enemy = enemy_ref.resolve()
		if (QDELETED(enemy))
			controller.blackboard[shitlist_key] -= enemy_ref
			continue
		if (enemy == living_mob) // Avoid a self-targetting feedback loop
			controller.blackboard[shitlist_key] -= enemy_ref
			continue
		if (!can_see(living_mob, enemy, vision_range))
			controller.blackboard[shitlist_key] -= enemy_ref
			continue
		if (!targetting_datum.can_attack(living_mob, enemy))
			controller.blackboard[shitlist_key] -= enemy_ref
			continue
		enemies_list += enemy

	if (!length(enemies_list))
		finish_action(controller, FALSE)
		return

	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if (target && (locate(target) in enemies_list)) // Don't bother changing
		finish_action(controller, FALSE)
		return

	var/atom/new_target = pick_final_target(controller, enemies_list)
	controller.blackboard[target_key] = WEAKREF(new_target)

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(living_mob, new_target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.blackboard[hiding_location_key] = WEAKREF(potential_hiding_location)

	finish_action(controller, TRUE)

/// Returns the desired final target from the filtered list of enemies
/datum/ai_behavior/target_from_retaliate_list/proc/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	return pick(enemies_list)
