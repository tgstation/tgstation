/datum/artifact_effect/borger
	weight = ARTIFACT_UNCOMMON
	type_name = "Borger Effect"
	activation_message = "opens up!"
	deactivation_message = "closes up."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)
	research_value = 2500
	examine_hint = span_bolddanger("It is vaguely forboding, <i>touching this might be a bad idea...</i>")
	examine_discovered = span_bolddanger("It will turn a random limb robotic if touched, <i>touching this might be a bad idea...</i>")
	/// The time between each limb replacement
	var/limb_replace_time = 1 SECONDS
	/// People who've already touched it once. Touching it again will cause it to react.
	var/list/first_touched
	/// The cooldown between borgings.
	COOLDOWN_DECLARE(borg_cooldown)

/datum/artifact_effect/borger/effect_touched(mob/living/user)
	if(!iscarbon(user) || !COOLDOWN_FINISHED(src, borg_cooldown) || QDELETED(user.client) || did_robot_touch(user))
		our_artifact.holder.visible_message(span_smallnoticeital("[our_artifact.holder] does not react to [user]."))
		return

	if(!LAZYACCESS(first_touched, user))
		eat_limb(user)
		LAZYSET(first_touched, user, TRUE)
		COOLDOWN_START(src, borg_cooldown, 5 SECONDS) // so you don't get fucked over by spam-clicking it
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

/datum/artifact_effect/borger/proc/eat_limb(mob/living/carbon/victim)
	var/arm_name = victim.get_held_index_name(victim.active_hand_index)
	victim.visible_message(span_warning("[our_artifact.holder] lashes out and clamps down on [victim], rapidly transmuting [victim.p_their()] [arm_name]!"), \
		span_userdanger("[our_artifact.holder] lashes out and clamps down onto your [arm_name], rapidly transmuting it into cold metal!"))
	var/new_arm_type = (victim.active_hand_index % 2) ? /obj/item/bodypart/arm/left/robot : /obj/item/bodypart/arm/right/robot
	victim.del_and_replace_bodypart(new new_arm_type)
	victim.emote("scream")

/datum/artifact_effect/borger/proc/did_robot_touch(mob/living/carbon/user)
	var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
	return istype(active_arm) && (active_arm.bodytype & BODYTYPE_ROBOTIC)
