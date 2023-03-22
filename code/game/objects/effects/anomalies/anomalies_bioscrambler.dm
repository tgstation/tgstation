
/obj/effect/anomaly/bioscrambler
	name = "bioscrambler anomaly"
	icon_state = "bioscrambler"
	aSignal = /obj/item/assembly/signaler/anomaly/bioscrambler
	immortal = TRUE
	/// Cooldown for every anomaly pulse
	COOLDOWN_DECLARE(pulse_cooldown)
	/// How many seconds between each anomaly pulses
	var/pulse_delay = 15 SECONDS
	/// Range of the anomaly pulse
	var/range = 5
	/// List of body parts which can be inserted
	var/static/list/body_parts
	/// Blacklist of parts which should not appear, largely because they will make you look totally fucked up
	var/static/list/parts_blacklist = list(
		/obj/item/bodypart/chest/larva,
		/obj/item/bodypart/head/larva,
		/obj/item/bodypart/leg/left/tallboy,
		/obj/item/bodypart/leg/right/tallboy,
	)
	/// List of organs which can be inserted
	var/static/list/organs
	/// Blacklist of organs which should not appear. Either will look terrible outside of intended, give you magical powers, or kill you
	var/static/list/organs_blacklist = list(
		/obj/item/organ/external/pod_hair,
		/obj/item/organ/external/spines,
		/obj/item/organ/external/wings/functional,
		/obj/item/organ/internal/body_egg,
		/obj/item/organ/internal/cyberimp,
		/obj/item/organ/internal/heart/cursed,
		/obj/item/organ/internal/heart/demon,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/monster_core,
		/obj/item/organ/internal/vocal_cords/colossus,
		/obj/item/organ/internal/zombie_infection,
	)

/obj/effect/anomaly/bioscrambler/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	if (!body_parts)
		body_parts = typesof(/obj/item/bodypart/chest) + typesof(/obj/item/bodypart/head) + subtypesof(/obj/item/bodypart/arm) + subtypesof(/obj/item/bodypart/leg)
		for (var/obj/item/bodypart/part as anything in body_parts)
			if (!is_path_in_list(part, parts_blacklist) && !(initial(part.bodytype) & BODYTYPE_ROBOTIC))
				continue
			body_parts -= part

	if(!organs)
		organs = subtypesof(/obj/item/organ/internal) + subtypesof(/obj/item/organ/external)
		for (var/obj/item/organ/organ_type as anything in organs)
			if (!is_path_in_list(organ_type, organs_blacklist) && !(initial(organ_type.organ_flags) & ORGAN_SYNTHETIC))
				continue
			organs -= organ_type

/obj/effect/anomaly/bioscrambler/anomalyEffect(delta_time)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return

	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	swap_parts(range)

/// Replaces your limbs and organs with something else
/obj/effect/anomaly/bioscrambler/proc/swap_parts(swap_range)
	for(var/mob/living/carbon/nearby in range(swap_range, src))
		if (nearby.run_armor_check(attack_flag = BIO, absorb_text = "Your armor protects you from [src]!") >= 100)
			continue //We are protected

		var/obj/item/organ/new_organ = pick(organs)
		new_organ = new new_organ()
		new_organ.replace_into(nearby)

		if (islarva(nearby))
			nearby.update_body(TRUE)
			balloon_alert(nearby, "something has changed about you")
			continue

		var/obj/item/bodypart/new_part = pick(body_parts)
		new_part = new new_part()
		var/obj/item/bodypart/picked_user_part = nearby.get_bodypart(new_part.body_zone)
		new_part.replace_limb(nearby, TRUE)
		if (picked_user_part)
			qdel(picked_user_part)

		nearby.update_body(TRUE)
		balloon_alert(nearby, "something has changed about you")
