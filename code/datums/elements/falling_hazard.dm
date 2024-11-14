/// An element that will make a target thing do damage to any mob that it falls on from a z-level above
/datum/element/falling_hazard
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The amount of damage to do when the target falls onto a mob
	var/fall_damage = 5
	/// The wound bonus to give damage dealt against mobs we fall on
	var/fall_wound_bonus = 0
	/// Does we take into consideration if the target has head protection (hardhat, or a strong enough helmet)
	var/obeys_hardhats = TRUE
	/// Does the target crush and flatten whoever it falls on
	var/crushes_people = FALSE
	/// What sound is played when the target falls onto a mob
	var/impact_sound = 'sound/effects/magic/clockwork/fellowship_armory.ogg' //CLANG

/datum/element/falling_hazard/Attach(datum/target, damage, wound_bonus, hardhat_safety, crushes, impact_sound)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.fall_damage = damage
	src.fall_wound_bonus = wound_bonus
	src.obeys_hardhats = hardhat_safety
	src.crushes_people = crushes
	src.impact_sound = impact_sound

	RegisterSignal(target, COMSIG_ATOM_ON_Z_IMPACT, PROC_REF(fall_onto_stuff))

/datum/element/falling_hazard/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ON_Z_IMPACT)

/// Gathers every mob in the turf the target falls on, and does damage/crushes them/makes a message about the target falling on them
/datum/element/falling_hazard/proc/fall_onto_stuff(datum/source, turf/impacted_turf, levels)
	SIGNAL_HANDLER

	var/mob/living/poor_target = locate(/mob/living) in impacted_turf

	if(!poor_target)
		return

	var/target_head_armor = poor_target.run_armor_check(BODY_ZONE_HEAD, MELEE, silent = TRUE)

	if(obeys_hardhats && target_head_armor >= 15) // 15 melee armor is enough that most head items dont have this, but anything above a hardhat should protect you
		poor_target.visible_message(
			span_warning("[source] falls on [poor_target], thankfully [poor_target.p_they()] had a helmet on!"),
			span_userdanger("You are hit on the head by [source], good thing you had a helmet on!"),
			span_hear("You hear a [crushes_people ? "crash" : "bonk"]!"),
		)

		if(crushes_people)
			poor_target.Knockdown(0.25 SECONDS * fall_damage) // For a piano, that would be 15 seconds

		playsound(poor_target, 'sound/items/weapons/parry.ogg', 50, TRUE) // You PARRIED the falling object with your EPIC hardhat
		return

	var/obj/item/bodypart/target_head = poor_target.get_bodypart(BODY_ZONE_HEAD)

	// This does more damage the more levels the falling object has fallen
	if(!crushes_people && target_head)
		poor_target.apply_damage(fall_damage * levels, def_zone = BODY_ZONE_HEAD, forced = TRUE, wound_bonus = fall_wound_bonus)
	else
		poor_target.apply_damage(fall_damage * levels, forced = TRUE, spread_damage = TRUE, wound_bonus = fall_wound_bonus)

	poor_target.visible_message(
		span_userdanger("[source] falls on [poor_target], [crushes_people ? "crushing [poor_target.p_them()]" : "hitting [poor_target.p_them()]"] [target_head ? "on the head!" : "!"]"),
		span_userdanger("You are [crushes_people ? "crushed" : "hit"] by [source]!"),
		span_hear("You hear a [crushes_people ? "crash" : "bonk"]!"),
	)

	playsound(poor_target, impact_sound, 50, TRUE)

	if(!crushes_people)
		return

	if(iscarbon(poor_target))
		poor_target.AddElement(/datum/element/squish, 30 SECONDS)
	poor_target.Paralyze(0.5 SECONDS * fall_damage) // For a piano, that would be 30 seconds
	add_memory_in_range(poor_target, 7, /datum/memory/witness_vendor_crush, protagonist = poor_target, antagonist = source)
