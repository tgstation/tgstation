/**
 * Can this atom be curshed by the vending machine
 * Arguments
 *
 * * atom/atom_target - the atom we are checking for
*/
/proc/check_atom_crushable(atom/atom_target)
	/// Contains structures and items that vendors shouldn't crush when we land on them.
	var/static/list/vendor_uncrushable_objects = list(
		/obj/structure/chair,
		/obj/machinery/conveyor,
	) + GLOB.WALLITEMS_INTERIOR + GLOB.WALLITEMS_EXTERIOR

	//make sure its not in the list of "uncrushable" stuff
	if(is_type_in_list(atom_target, vendor_uncrushable_objects))
		return FALSE

	//check if it has integrity + allow ninjas, etc to be crushed in cloak
	if (atom_target.uses_integrity && !(atom_target.invisibility > SEE_INVISIBLE_LIVING))
		return TRUE //SMUSH IT

	return FALSE

/**
 * Causes src to fall onto [target], crushing everything on it (including itself) with [damage]
 * and a small chance to do a spectacular effect per entity (if a chance above 0 is provided).
 *
 * Args:
 * * turf/target: The turf to fall onto. Cannot be null.
 * * damage: The raw numerical damage to do by default.
 * * chance_to_crit: The percent chance of a critical hit occurring. Default: 0
 * * forced_crit_case: If given a value from crushing.dm, [target] and its contents will always be hit with that specific critical hit. Default: null
 * * paralyze_time: The time, in deciseconds, a given mob/living will be paralyzed for if crushed.
 * * crush_dir: The direction the crush is coming from. Default: dir of src to [target].
 * * damage_type: The type of damage to do. Default: BRUTE
 * * damage_flag: The attack flag for armor purposes. Default: MELEE
 * * rotation: The angle of which to rotate src's transform by on a successful tilt. Default: 90.
 *
 * Returns: A collection of bitflags defined in crushing.dm. Read that file's documentation for info.
 */
/atom/movable/proc/fall_and_crush(turf/target, damage, chance_to_crit = 0, forced_crit_case = null, paralyze_time, crush_dir = get_dir(get_turf(src), target), damage_type = BRUTE, damage_flag = MELEE, rotation = 90)

	ASSERT(!isnull(target))

	var/flags_to_return = NONE

	if (!target.is_blocked_turf(TRUE, src, list(src)))
		for(var/atom/atom_target in (target.contents) + target)
			if (isarea(atom_target))
				continue

			if (SEND_SIGNAL(atom_target, COMSIG_PRE_TILT_AND_CRUSH, src) & COMPONENT_IMMUNE_TO_TILT_AND_CRUSH)
				continue

			var/crit_case = forced_crit_case
			if (isnull(crit_case) && chance_to_crit > 0)
				if (prob(chance_to_crit))
					crit_case = pick_weight(get_crit_crush_chances())
			var/crit_rebate_mult = 1 // lessen the normal damage we deal for some of the crits

			if (!isnull(crit_case))
				crit_rebate_mult = fall_and_crush_crit_rebate_table(crit_case)
				apply_crit_crush(crit_case, atom_target)

			var/adjusted_damage = damage * crit_rebate_mult
			var/crushed
			if (isliving(atom_target))
				crushed = TRUE
				var/mob/living/carbon/living_target = atom_target
				var/was_alive = living_target.stat != DEAD
				var/blocked = living_target.run_armor_check(attack_flag = damage_flag)
				if (iscarbon(living_target))
					var/mob/living/carbon/carbon_target = living_target
					if(prob(30))
						carbon_target.apply_damage(max(0, adjusted_damage), damage_type, blocked = blocked, forced = TRUE, spread_damage = TRUE, attack_direction = crush_dir) // the 30% chance to spread the damage means you escape breaking any bones
					else
						var/brute = (damage_type == BRUTE ? damage : 0) * 0.5
						var/burn = (damage_type == BURN ? damage : 0) * 0.5
						carbon_target.take_bodypart_damage(brute, burn, check_armor = TRUE, wound_bonus = 5) // otherwise, deal it to 2 random limbs (or the same one) which will likely shatter something
						carbon_target.take_bodypart_damage(brute, burn, check_armor = TRUE, wound_bonus = 5)
					carbon_target.AddElement(/datum/element/squish, 80 SECONDS)
				else
					living_target.apply_damage(adjusted_damage, damage_type, blocked = blocked, forced = TRUE, attack_direction = crush_dir)

				living_target.Paralyze(paralyze_time)
				living_target.emote("scream")
				playsound(living_target, 'sound/effects/blob/blobattack.ogg', 40, TRUE)
				playsound(living_target, 'sound/effects/splat.ogg', 50, TRUE)
				post_crush_living(living_target, was_alive)
				flags_to_return |= (SUCCESSFULLY_CRUSHED_MOB|SUCCESSFULLY_CRUSHED_ATOM)

			else if(check_atom_crushable(atom_target))
				atom_target.take_damage(adjusted_damage, damage_type, damage_flag, FALSE, crush_dir)
				crushed = TRUE
				flags_to_return |= SUCCESSFULLY_CRUSHED_ATOM

			if (crushed)
				atom_target.visible_message(span_danger("[atom_target] is crushed by [src]!"), span_userdanger("You are crushed by [src]!"))
				SEND_SIGNAL(atom_target, COMSIG_POST_TILT_AND_CRUSH, src)

		var/matrix/to_turn = turn(transform, rotation)
		animate(src, transform = to_turn, 0.2 SECONDS)
		playsound(src, 'sound/effects/bang.ogg', 40)

		visible_message(span_danger("[src] tips over, slamming hard onto [target]!"))
		flags_to_return |= SUCCESSFULLY_FELL_OVER
		post_tilt()
	else
		visible_message(span_danger("[src] rebounds comically as it fails to slam onto [target]!"))

	Move(target, crush_dir) // we still TRY to move onto it for shit like teleporters
	return flags_to_return

/**
 * Returns a assoc list of (critcase -> num), where critcase is a critical define in crushing.dm and num is a weight.
 * Use with pickweight to acquire a random critcase.
 */
/atom/movable/proc/get_crit_crush_chances()
	RETURN_TYPE(/list)

	return list(
		CRUSH_CRIT_SHATTER_LEGS = 100,
		CRUSH_CRIT_PARAPLEGIC = 80,
		CRUSH_CRIT_HEADGIB = 20,
		CRUSH_CRIT_SQUISH_LIMB = 100
	)

/**
 * Exists for the purposes of custom behavior.
 * Called directly after [crushed] is crushed.
 *
 * Args:
 * * mob/living/crushed: The mob that was crushed.
 * * was_alive: Boolean. True if the mob was alive before the crushing.
 */
/atom/movable/proc/post_crush_living(mob/living/crushed, was_alive)
	return

/**
 * Exists for the purposes of custom behavior.
 * Called directly after src actually rotates and falls over.
 */
/atom/movable/proc/post_tilt()
	return

/**
 * Should be where critcase effects are actually implemented. Use this to apply critcases.
 * Args:
 * * crit_case: The chosen critcase, defined in crushing.dm.
 * * atom/atom_target: The target to apply the critical hit to. Cannot be null. Can be anything except /area.
 *
 * Returns:
 * TRUE if a crit case is successfully applied, FALSE otherwise.
 */
/atom/movable/proc/apply_crit_crush(crit_case, atom/atom_target)
	switch (crit_case)
		if(CRUSH_CRIT_SHATTER_LEGS) // shatter their legs and bleed 'em
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			carbon_target.bleed(150)
			var/obj/item/bodypart/leg/left/left_leg = carbon_target.get_bodypart(BODY_ZONE_L_LEG)
			if(left_leg)
				left_leg.receive_damage(brute = 200)
			var/obj/item/bodypart/leg/right/right_leg = carbon_target.get_bodypart(BODY_ZONE_R_LEG)
			if(right_leg)
				right_leg.receive_damage(brute = 200)
			if(left_leg || right_leg)
				carbon_target.visible_message(span_danger("[carbon_target]'s legs shatter with a sickening crunch!"), span_userdanger("Your legs shatter with a sickening crunch!"))
			return TRUE
		if(CRUSH_CRIT_PARAPLEGIC) // paralyze this binch
			// the new paraplegic gets like 4 lines of losing their legs so skip them
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			visible_message(span_danger("[carbon_target]'s spinal cord is obliterated with a sickening crunch!"), ignored_mobs = list(carbon_target))
			carbon_target.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic)
			return TRUE
		if(CRUSH_CRIT_SQUISH_LIMB) // limb squish!
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			for(var/obj/item/bodypart/squish_part in carbon_target.bodyparts)
				var/severity = pick(WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_SEVERE, WOUND_SEVERITY_CRITICAL)
				if (!carbon_target.cause_wound_of_type_and_severity(WOUND_BLUNT, squish_part, severity, wound_source = "crushed by [src]"))
					squish_part.receive_damage(brute = 30)
			carbon_target.visible_message(span_danger("[carbon_target]'s body is maimed underneath the mass of [src]!"), span_userdanger("Your body is maimed underneath the mass of [src]!"))
			return TRUE
		if(CRUSH_CRIT_HEADGIB) // skull squish!
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			var/obj/item/bodypart/head/carbon_head = carbon_target.get_bodypart(BODY_ZONE_HEAD)
			if(carbon_head)
				if(carbon_head.dismember())
					carbon_target.visible_message(span_danger("[carbon_head] explodes in a shower of gore beneath [src]!"),	span_userdanger("Oh f-"))
					carbon_head.drop_organs()
					qdel(carbon_head)
					new /obj/effect/gibspawner/human/bodypartless(get_turf(carbon_target), carbon_target)
			return TRUE

	return FALSE

/**
 * Tilts ontop of the atom supplied, if crit is true some extra shit can happen. See [fall_and_crush] for return values.
 * Arguments:
 * fatty - atom to tilt the vendor onto
 * local_crit_chance - percent chance of a critical hit
 * forced_crit - specific critical hit case to use, if any
 * range - the range of the machine when thrown if not adjacent
*/
/obj/machinery/vending/proc/tilt(atom/fatty, local_crit_chance = crit_chance, forced_crit, range = 1)
	if(QDELETED(src) || !has_gravity(src))
		return

	. = NONE

	var/picked_rotation = pick(90, 270)
	if(Adjacent(fatty))
		. = fall_and_crush(get_turf(fatty), squish_damage, local_crit_chance, forced_crit, 6 SECONDS, rotation = picked_rotation)

		if (. & SUCCESSFULLY_FELL_OVER)
			visible_message(span_danger("[src] tips over!"))
			tilted = TRUE
			tilted_rotation = picked_rotation
			layer = ABOVE_MOB_LAYER

	if(get_turf(fatty) != get_turf(src))
		throw_at(get_turf(fatty), range, 1, spin = FALSE, quickstart = FALSE)

/obj/machinery/vending/post_crush_living(mob/living/crushed, was_alive)

	if(was_alive && crushed.stat == DEAD && crushed.client)
		crushed.client.give_award(/datum/award/achievement/misc/vendor_squish, crushed) // good job losing a fight with an inanimate object idiot

	add_memory_in_range(crushed, 7, /datum/memory/witness_vendor_crush, protagonist = crushed, antagonist = src)

	return ..()

/**
 * Allows damage to be reduced on certain crit cases.
 * Args:
 * * crit_case: The critical case chosen.
 */
/atom/movable/proc/fall_and_crush_crit_rebate_table(crit_case)
	ASSERT(!isnull(crit_case))

	switch(crit_case)
		if (CRUSH_CRIT_SHATTER_LEGS)
			return 0.2
		else
			return 1

/obj/machinery/vending/fall_and_crush_crit_rebate_table(crit_case)
	return crit_case == VENDOR_CRUSH_CRIT_GLASSCANDY ? 0.33 : ..()

/obj/machinery/vending/get_crit_crush_chances()
	return list(
		VENDOR_CRUSH_CRIT_GLASSCANDY = 100,
		VENDOR_CRUSH_CRIT_PIN = 100
	)

/obj/machinery/vending/apply_crit_crush(crit_case, atom_target)
	. = ..()
	if (.)
		return TRUE

	switch (crit_case)
		if (VENDOR_CRUSH_CRIT_GLASSCANDY)
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			for(var/i in 1 to 7)
				var/obj/item/shard/shard = new /obj/item/shard(get_turf(carbon_target))
				var/datum/embedding/embed = shard.get_embed()
				embed.embed_chance = 100
				embed.ignore_throwspeed_threshold = TRUE
				embed.impact_pain_mult = 1
				carbon_target.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
				embed.embed_chance = initial(embed.embed_chance)
				embed.ignore_throwspeed_threshold = initial(embed.ignore_throwspeed_threshold)
				embed.impact_pain_mult = initial(embed.impact_pain_mult)
			return TRUE
		if (VENDOR_CRUSH_CRIT_PIN) // pin them beneath the machine until someone untilts it
			if (!isliving(atom_target))
				return FALSE
			var/mob/living/living_target = atom_target
			forceMove(get_turf(living_target))
			buckle_mob(living_target, force=TRUE)
			living_target.visible_message(span_danger("[living_target] is pinned underneath [src]!"), span_userdanger("You are pinned down by [src]!"))
			return TRUE

	return FALSE

/**
 * Rights the vendor up, unpinning mobs under it, if any.
 * Arguments:
 * user - mob that has untilted the vendor
 */
/obj/machinery/vending/proc/untilt(mob/user)
	if(user)
		user.visible_message(span_notice("[user] rights [src]."), \
			span_notice("You right [src]."))

	unbuckle_all_mobs(TRUE)

	tilted = FALSE
	layer = initial(layer)

	var/matrix/to_turn = turn(transform, -tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)
	tilted_rotation = 0
