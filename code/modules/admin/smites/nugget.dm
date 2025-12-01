/// Rips off all the limbs of the target
/datum/smite/nugget
	name = "Nugget"

/datum/smite/nugget/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	var/timer = 2 SECONDS
	for (var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		if (limb.body_part == HEAD || limb.body_part == CHEST)
			continue
		addtimer(CALLBACK(limb, TYPE_PROC_REF(/obj/item/bodypart/, dismember)), timer)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), carbon_target, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 70), timer)
		addtimer(CALLBACK(carbon_target, TYPE_PROC_REF(/mob/living/, spin), 4, 1), timer - 0.4 SECONDS)
		timer += 2 SECONDS
