/datum/component/artifact/borger
	associated_object = /obj/structure/artifact/borger
	weight = ARTIFACT_UNCOMMON
	type_name = "Borger"
	activation_message = "opens up!"
	deactivation_message = "closes up."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)
	///the time between each limb replacement
	var/limb_replace_time = 1 SECONDS
	COOLDOWN_DECLARE(borg_cooldown)

/datum/component/artifact/borger/effect_touched(mob/living/user)
	if(!iscarbon(user) || !COOLDOWN_FINISHED(src, borg_cooldown))
		holder.visible_message(span_smallnoticeital("[holder] does not react to [user]."))
		return

	var/mob/living/carbon/carbon_target = user
	var/timer = 2 SECONDS
	for (var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		if (limb.body_part == HEAD || limb.body_part == CHEST)
			continue
		switch(limb.body_part)
			if(ARM_RIGHT)
				var/obj/item/bodypart/arm/right/robot/new_limb = new
				addtimer(CALLBACK(new_limb, TYPE_PROC_REF(/obj/item/bodypart/, try_attach_limb), carbon_target), timer + 5)
			if(ARM_LEFT)
				var/obj/item/bodypart/arm/left/robot/new_limb = new
				addtimer(CALLBACK(new_limb, TYPE_PROC_REF(/obj/item/bodypart/, try_attach_limb), carbon_target), timer + 5)
			if(LEG_RIGHT)
				var/obj/item/bodypart/leg/right/robot/new_limb = new
				addtimer(CALLBACK(new_limb, TYPE_PROC_REF(/obj/item/bodypart/, try_attach_limb), carbon_target), timer + 5)
			if(LEG_LEFT)
				var/obj/item/bodypart/leg/left/robot/new_limb = new
				addtimer(CALLBACK(new_limb, TYPE_PROC_REF(/obj/item/bodypart/, try_attach_limb), carbon_target), timer + 5)

		addtimer(CALLBACK(limb, TYPE_PROC_REF(/obj/item/bodypart/, dismember)), timer)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), carbon_target, 'sound/effects/cartoon_pop.ogg', 70), timer)
		addtimer(CALLBACK(carbon_target, TYPE_PROC_REF(/mob/living/, spin), 4, 1), timer - 0.4 SECONDS)
		timer += 2 SECONDS
	addtimer(CALLBACK(carbon_target, TYPE_PROC_REF(/mob/, Robotize)), timer + 5)
	COOLDOWN_START(src, borg_cooldown, 10 SECONDS)
