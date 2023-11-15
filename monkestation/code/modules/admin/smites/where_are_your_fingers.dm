/// Rips off the target's arms
/datum/smite/where_are_your_fingers
	name = "Where are your fingers?"

/datum/smite/where_are_your_fingers/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), carbon_target, 'monkestation/sound/effects/ggg/whereareyourfingers.mp3', 70), 0 SECONDS)

	for (var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		if (limb.body_part == HEAD || limb.body_part == CHEST || limb.body_part == LEG_LEFT || limb.body_part == LEG_RIGHT)
			continue
		addtimer(CALLBACK(limb, TYPE_PROC_REF(/obj/item/bodypart/, dismember)), 5 SECONDS)
