/datum/ai_behavior/hunt_target/interact_with_target/heal_raptor
	always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/injured_raptor
	action_cooldown = 7.5 SECONDS

/datum/ai_behavior/find_hunt_target/injured_raptor/valid_dinner(mob/living/source, mob/living/target, radius)
	return (source != target && target.health < target.maxHealth)

/datum/ai_behavior/find_hunt_target/raptor_baby/valid_dinner(mob/living/source, mob/living/target, radius)
	return can_see(source, target, radius) && target.stat != DEAD

/datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off/care_for_young

/datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off/care_for_young/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("grooms [hunted]!")
	return ..()

/datum/ai_behavior/find_hunt_target/raptor_trough
	action_cooldown = 7.5 SECONDS

/datum/ai_behavior/find_hunt_target/raptor_trough/valid_dinner(mob/living/source, atom/movable/trough, radius)
	return !!(locate(/obj/item/stack/ore) in trough.contents)
