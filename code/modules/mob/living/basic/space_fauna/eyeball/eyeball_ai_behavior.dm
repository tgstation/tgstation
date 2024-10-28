/datum/ai_behavior/find_the_blind

/datum/ai_behavior/find_the_blind/perform(seconds_per_tick, datum/ai_controller/controller, blind_key, threshold_key)
	var/mob/living_pawn = controller.pawn
	var/list/blind_list = list()
	var/eye_damage_threshold = controller.blackboard[threshold_key]
	if(!eye_damage_threshold)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/mob/living/carbon/blind in oview(9, living_pawn))
		var/obj/item/organ/internal/eyes/eyes = blind.get_organ_slot(ORGAN_SLOT_EYES)
		if(isnull(eyes))
			continue
		if(eyes.damage < eye_damage_threshold)
			continue
		blind_list += blind

	if(!length(blind_list))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(blind_key, pick(blind_list))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/heal_eye_damage
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/heal_eye_damage/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/carbon/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/heal_eye_damage/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/carbon/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/obj/item/organ/internal/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	var/datum/callback/callback = CALLBACK(living_pawn, TYPE_PROC_REF(/mob/living/basic/eyeball, heal_eye_damage), target, eyes)
	callback.Invoke()

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/heal_eye_damage/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/targeted_mob_ability/glare_at_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/targeted_mob_ability/glare_at_target/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if (isnull(target))
		return FALSE

	var/turf/turf_to_move_towards = get_step(target, target.dir)
	if(turf_to_move_towards.is_blocked_turf(ignore_atoms = list(controller.pawn)))
		return FALSE

	if(isnull(turf_to_move_towards))
		return FALSE

	set_movement_target(controller, turf_to_move_towards)

/datum/ai_behavior/targeted_mob_ability/glare_at_target/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	var/mob/living/target = controller.blackboard[target_key]

	if(QDELETED(ability) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/direction_to_compare = get_dir(target, controller.pawn)
	var/target_direction = target.dir
	if(direction_to_compare != target_direction)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/result = ability.InterceptClickOn(controller.pawn, null, target)
	if(result == TRUE)
		return AI_BEHAVIOR_INSTANT
	else
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/hunt_target/interact_with_target/carrot
	hunt_cooldown = 2 SECONDS
	always_reset_target = TRUE
