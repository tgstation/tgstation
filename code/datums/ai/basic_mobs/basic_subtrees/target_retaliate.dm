/// Sets the BB target to a mob which you can see and who has recently attacked you
/datum/ai_planning_subtree/target_retaliate
	/// Blackboard key which tells us how to select valid targets
	var/targetting_datum_key = BB_TARGETTING_DATUM
	/// Blackboard key in which to store selected target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Blackboard key in which to store selected target's hiding place
	var/hiding_place_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION

/datum/ai_planning_subtree/target_retaliate/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/target_from_retaliate_list, BB_BASIC_MOB_RETALIATE_LIST, target_key, targetting_datum_key, hiding_place_key)

/// Places a mob which you can see and who has recently attacked you into some 'run away from this' AI keys
/// Can use a different targetting datum than you use to select attack targets
/// Not required if fleeing is the only target behaviour or uses the same target datum
/datum/ai_planning_subtree/target_retaliate/to_flee
	targetting_datum_key = BB_FLEE_TARGETTING_DATUM
	target_key = BB_BASIC_MOB_FLEE_TARGET
	hiding_place_key = BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION

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
		finish_action(controller, succeeded = FALSE)
		return

	var/list/enemies_list = list()
	for (var/datum/weakref/enemy_ref as anything in enemy_refs)
		var/atom/enemy = enemy_ref.resolve()
		if (!can_attack_target(living_mob, enemy, targetting_datum))
			controller.blackboard[shitlist_key] -= enemy_ref
			continue
		enemies_list += enemy

	if (!length(enemies_list))
		finish_action(controller, succeeded = FALSE)
		return

	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if (target && (locate(target) in enemies_list)) // Don't bother changing
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/new_target = pick_final_target(controller, enemies_list)
	controller.blackboard[target_key] = WEAKREF(new_target)

	var/atom/potential_hiding_location = targetting_datum.find_hidden_mobs(living_mob, new_target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.blackboard[hiding_location_key] = WEAKREF(potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/// Returns true if this target is valid for attacking based on current conditions
/datum/ai_behavior/target_from_retaliate_list/proc/can_attack_target(mob/living/living_mob, atom/target, datum/targetting_datum/targetting_datum)
	if (!target)
		return FALSE
	if (target == living_mob)
		return FALSE
	if (!can_see(living_mob, target, vision_range))
		return FALSE
	return targetting_datum.can_attack(living_mob, target)

/// Returns the desired final target from the filtered list of enemies
/datum/ai_behavior/target_from_retaliate_list/proc/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	return pick(enemies_list)
