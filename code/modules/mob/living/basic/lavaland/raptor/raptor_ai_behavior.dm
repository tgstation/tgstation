/datum/ai_behavior/hunt_target/interact_with_target/heal_raptor
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/injured_raptor
	action_cooldown = 7.5 SECONDS

/datum/ai_behavior/find_hunt_target/injured_raptor/valid_dinner(mob/living/source, mob/living/target, radius)
	return (source != target && target.health < target.maxHealth)

/datum/ai_behavior/find_hunt_target/raptor_baby/valid_dinner(mob/living/source, mob/living/target, radius)
	if (!can_see(source, target, radius) || target.stat == DEAD || !istype(target, /mob/living/basic/raptor))
		return FALSE
	var/mob/living/basic/raptor/raptor = target
	return raptor.growth_stage == RAPTOR_BABY

/datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off/care_for_young

/datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off/care_for_young/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("grooms [hunted]!")
	return ..()

/datum/ai_behavior/find_hunt_target/raptor_trough
	action_cooldown = 7.5 SECONDS

/datum/ai_behavior/find_hunt_target/raptor_trough/valid_dinner(mob/living/source, atom/movable/trough, radius)
	return !!(locate(/obj/item/stack/ore) in trough.contents)

/datum/ai_behavior/find_injured_rider/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	var/mob/living/living_mob = controller.pawn
	if (!length(living_mob.buckled_mobs) || !isliving(living_mob.buckled_mobs[1]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/rider = living_mob.buckled_mobs[1]
	if (rider.stat == CONSCIOUS || rider.stat == DEAD || rider.health >= rider.maxHealth)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(hunting_target_key, rider)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
