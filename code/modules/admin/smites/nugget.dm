/// Rips off all the limbs of the target
/datum/smite/nugget
	name = "Nugget"

/datum/smite/nugget/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	var/timer = 2 SECONDS
	for (var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		if (limb.body_part == HEAD || limb.body_part == CHEST)
			continue
		addtimer(CALLBACK(limb, /obj/item/bodypart/.proc/dismember), timer)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, carbon_target, 'sound/effects/cartoon_pop.ogg', 70), timer)
		addtimer(CALLBACK(carbon_target, /mob/living/.proc/spin, 4, 1), timer - 0.4 SECONDS)
		timer += 2 SECONDS
