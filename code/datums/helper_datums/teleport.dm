// teleatom: atom to teleport
// destination: destination to teleport to
// precision: teleport precision (0 is most precise, the default)
// effectin: effect to show right before teleportation
// effectout: effect to show right after teleportation
// asoundin: soundfile to play before teleportation
// asoundout: soundfile to play after teleportation
// no_effects: disable the default effectin/effectout of sparks
// forced: whether or not to ignore no_teleport
/proc/do_teleport(atom/movable/teleatom, atom/destination, precision=null, datum/effect_system/effectin=null, datum/effect_system/effectout=null, asoundin=null, asoundout=null, no_effects=FALSE, channel=TELEPORT_CHANNEL_BLUESPACE, forced = FALSE)
	// teleporting most effects just deletes them
	var/static/list/delete_atoms = zebra_typecacheof(list(
		/obj/effect = TRUE,
		/obj/effect/dummy/chameleon = FALSE,
		/obj/effect/wisp = FALSE,
		/obj/effect/mob_spawn = FALSE,
		/obj/effect/immovablerod = FALSE,
		/obj/effect/meteor = FALSE,
	))
	if(delete_atoms[teleatom.type])
		qdel(teleatom)
		return FALSE

	// argument handling
	// if the precision is not specified, default to 0, but apply BoH penalties
	if(isnull(precision))
		precision = 0

	switch(channel)
		if(TELEPORT_CHANNEL_BLUESPACE)
			var/interference = 0
			for(var/obj/item/check as anything in teleatom.get_all_contents_type(/obj/item))
				if(check.item_flags & BLUESPACE_INTERFERENCE)
					interference += 1
			if(interference)
				precision = max(rand(1,100)*interference,100)
				if(isliving(teleatom))
					var/mob/living/MM = teleatom
					to_chat(MM, span_warning("The clashing pulls of bluespace interfere with your teleport!"))

			// if effects are not specified and not explicitly disabled, sparks
			if((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/basic/spark_spread/sparks = new(teleatom, 5, TRUE)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks
		if(TELEPORT_CHANNEL_QUANTUM)
			// if effects are not specified and not explicitly disabled, rainbow sparks
			if ((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/basic/spark_spread/quantum/sparks = new(teleatom, 5, TRUE)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks

	// perform the teleport
	var/turf/curturf = get_turf(teleatom)
	if(!curturf)
		return FALSE

	//The final destination chosen after a few checks
	var/turf/destturf
	//The turf of the original destination from the args
	var/turf/og_destination = get_turf(destination)
	if(precision)
		destturf = get_valid_teleport_turf(curturf, og_destination, precision, skip_restrictions = forced)
	else if(!og_destination.is_transition_turf())
		destturf = og_destination

	if(!destturf || (!forced && !check_teleport_valid(teleatom, destturf, channel, original_destination = destination)))
		if(ismob(teleatom))
			teleatom.balloon_alert(teleatom, "something holds you back!")
		return FALSE

	if(SEND_SIGNAL(teleatom, COMSIG_MOVABLE_TELEPORTING, destination, channel))
		return FALSE
	if(SEND_SIGNAL(destturf, COMSIG_ATOM_INTERCEPT_TELEPORTING, channel, curturf))
		return FALSE

	if(isobserver(teleatom))
		teleatom.abstract_move(destturf)
		return TRUE

	tele_play_specials(teleatom, curturf, effectin, asoundin)

	var/success = teleatom.forceMove(destturf)
	if(!success)
		return FALSE

	. = TRUE
	/* Past this point, the teleport is successful and you can assume that they're already there */

	log_game("[key_name(teleatom)] has teleported from [loc_name(curturf)] to [loc_name(destturf)]")
	tele_play_specials(teleatom, destturf, effectout, asoundout)

	if(ismob(teleatom))
		var/mob/M = teleatom
		teleatom.log_message("teleported from [loc_name(curturf)] to [loc_name(destturf)].", LOG_GAME, log_globally = FALSE)
		M.cancel_camera()

	SEND_SIGNAL(teleatom, COMSIG_MOVABLE_POST_TELEPORT, destination, channel)

	//We need to be sure that the buckled mobs can teleport too
	if(teleatom.has_buckled_mobs())
		for(var/mob/living/rider in teleatom.buckled_mobs)
			//just in case it fails, but the mob gets unbuckled anyways even if it passes
			teleatom.unbuckle_mob(rider, TRUE, FALSE)

			var/rider_success = do_teleport(rider, destturf, precision, channel=channel, no_effects=TRUE)
			if(!rider_success)
				continue

			if(get_turf(rider) != destturf) //precision made them teleport somewhere else
				to_chat(rider, span_warning("As you reorient your senses, you realize you aren't riding [teleatom] anymore!"))
				continue

			// [mob/living].forceMove() forces mobs to unbuckle, so we need to buckle them again
			teleatom.buckle_mob(rider, force=TRUE)

/proc/tele_play_specials(atom/movable/teleatom, atom/location, datum/effect_system/effect, sound)
	if(!location)
		return

	if(sound)
		playsound(location, sound, 60, TRUE)
	if(effect)
		effect.attach(location).start()

/**
 * Attempts to find a "safe" floor turf within some given z-levels
 * * zlevel_or_levels: The list of z-levels we are searching though. You can supply just a number and it will be turned into a list.
 * * extended_safety_checks: Will do some additional checks to make sure the destination is safe, see [/proc/is_safe_turf].
 * * dense_atoms: Will additionally check to see if the turf has any dense obstructions, like machines or structures.
 *
 * Returns a safe floor turf,
 * **BUT** there is a chance of it being null if an extremely large portion of a z-level is unsafe or blocked.
 */
/proc/find_safe_turf(zlevel_or_levels, extended_safety_checks = FALSE, dense_atoms = FALSE) as /turf/open/floor
	SHOULD_BE_PURE(TRUE)
	RETURN_TYPE(/turf/open/floor)

	var/list/zlevels
	if(islist(zlevel_or_levels))
		zlevels = zlevel_or_levels
	else if(zlevel_or_levels)
		zlevels = list(zlevel_or_levels)
	else
		zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)

	for(var/cycle in 1 to 1000)
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = pick(zlevels)
		var/random_location = locate(x,y,z)
		var/keep_trying_no_teleport = (cycle < 300) //if the area is mostly NOTELEPORT (centcom) we gotta give up on this fantasy at some point.
		if(is_safe_turf(random_location, extended_safety_checks, dense_atoms, keep_trying_no_teleport))
			return random_location

/**
 * Checks to see if a given turf is a "safe" location. Being safe requires the following to be true:
 * * Must be a [floor][/turf/open/floor]
 * * Must have air, and that air must have [breathable bounds][/proc/check_gases] for humans
 * * Must have goldilocks temperature
 * * Must have safe pressure
 *
 * Optionally:
 * * extended_safety_checks: Will make additional checks for turfs that technically pass all previous requirements but still may not be safe
 * * dense_atoms: Must be unobstructed (no blocking objects such as machines, structures or mobs)
 * * no_teleport: Must not have [NOTELEPORT][/area/var/area_flag]
 *
 * Returns TRUE if all conditions pass, FALSE otherwise.
 */
/proc/is_safe_turf(turf/random_location, extended_safety_checks = FALSE, dense_atoms = FALSE, no_teleport = FALSE)
	SHOULD_BE_PURE(TRUE)

	. = FALSE
	if(!isfloorturf(random_location))
		return
	var/turf/open/floor/floor_turf = random_location
	var/area/destination_area = floor_turf.loc

	if(no_teleport && (destination_area.area_flags & NOTELEPORT))
		return

	var/datum/gas_mixture/floor_gas_mixture = floor_turf.air
	if(!floor_gas_mixture)
		return

	var/list/floor_gases = floor_gas_mixture.gases
	var/static/list/gases_to_check = list(
		/datum/gas/oxygen = list(/obj/item/organ/lungs::safe_oxygen_min, 100),
		/datum/gas/nitrogen,
		/datum/gas/carbon_dioxide = list(0, /obj/item/organ/lungs::safe_co2_max)
	)
	if(!check_gases(floor_gases, gases_to_check))
		return FALSE

	// Aim for goldilocks temperatures and pressure
	if((floor_gas_mixture.temperature <= BODYTEMP_COLD_DAMAGE_LIMIT) || (floor_gas_mixture.temperature >= BODYTEMP_HEAT_DAMAGE_LIMIT))
		return
	var/pressure = floor_gas_mixture.return_pressure()
	if((pressure <= HAZARD_LOW_PRESSURE) || (pressure >= HAZARD_HIGH_PRESSURE))
		return

	if(extended_safety_checks)
		if(islava(floor_turf)) //chasms aren't /floor, and so are pre-filtered
			var/turf/open/lava/lava_turf = floor_turf // Cyberboss: okay, this makes no sense and I don't understand the above comment, but I'm too lazy to check history to see what it's supposed to do right now
			if(!lava_turf.is_safe())
				return

	// Check that we're not warping onto a table or window
	if(!dense_atoms)
		var/density_found = FALSE
		for(var/atom/movable/found_movable in floor_turf)
			if(found_movable.density)
				density_found = TRUE
				break
		if(density_found)
			return

	// DING! You have passed the gauntlet, and are "probably" safe.
	return TRUE

///Check for turfs within range of the center turf and perform simple checks to see which is a valid teleportation target. If so, add it to a list to pick the final destination from at the end.
/proc/get_valid_teleport_turf(turf/origin, turf/center, range = 0, skip_restrictions = FALSE)
	var/list/turfs = list()
	var/area/origin_area = origin.loc
	for(var/turf/turf as anything in RANGE_TURFS(range, center))
		if(turf.is_transition_turf())
			continue // Avoid picking these at all cost
		if(skip_restrictions)
			turfs.Add(turf)
			continue

		if(HAS_TRAIT(turf, TRAIT_NO_TELEPORT))
			continue
		var/area/area = turf.loc
		if(area.area_flags & NOTELEPORT)
			continue
		if(((origin_area.area_flags & LOCAL_TELEPORT) || (area.area_flags & LOCAL_TELEPORT)) && origin_area != area)
			continue
		turfs.Add(turf)

	if (length(turfs))
		return pick(turfs)
	return null

/// Validates that the teleport being attempted is valid or not
/proc/check_teleport_valid(atom/teleported_atom, atom/destination, channel, atom/original_destination = null)
	SHOULD_BE_PURE(TRUE)

	if(isnull(destination))
		return FALSE // Teleporting FROM nullspace is fine, but TO nullspace is not

	var/area/origin_area = get_area(teleported_atom)

	var/area/destination_area = get_area(destination)
	var/turf/destination_turf = get_turf(destination)

	if(HAS_TRAIT(teleported_atom, TRAIT_NO_TELEPORT) || HAS_TRAIT(destination_turf, TRAIT_NO_TELEPORT))
		return FALSE

	// prevent unprecise teleports from landing you outside of the destination's reserved area
	if(is_reserved_level(destination_turf.z) && istype(original_destination) \
		&& SSmapping.get_reservation_from_turf(destination_turf) != SSmapping.get_reservation_from_turf(get_turf(original_destination)))
		return FALSE

	if((origin_area.area_flags & NOTELEPORT) || (destination_area.area_flags & NOTELEPORT))
		return FALSE

	// If one of the areas you're trying to tp to has local_teleport, and they're not the same, return.
	if(((origin_area.area_flags & LOCAL_TELEPORT) || (destination_area.area_flags & LOCAL_TELEPORT)) && destination_area != origin_area)
		return FALSE

	return TRUE

//Gets the topmost teleportable container
/proc/get_teleportable_container(atom/movable/teleportable, container_flags = ALL)
	while(ismovable(teleportable.loc))
		if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_STORAGE) && isitem(teleportable))
			var/obj/item/item = teleportable
			if(item.item_flags & IN_STORAGE)
				break
		var/atom/movable/movable = teleportable.loc
		if(movable.anchored)
			break
		if(isliving(movable))
			var/mob/living/living = movable
			if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_INVENTORY))
				var/list/equipped = living.get_equipped_items(INCLUDE_HELD|INCLUDE_POCKETS)
				if((teleportable in equipped) && !HAS_TRAIT(teleportable, TRAIT_NODROP))
					if(istype(teleportable, /obj/item/mod/control) && (container_flags & TELEPORT_CONTAINER_INCLUDE_SEALED_MODSUIT))
						var/obj/item/mod/control/modsuit = teleportable
						var/sealed = TRUE
						for(var/datum/mod_part/part as anything in modsuit.get_part_datums(TRUE))
							if((part.part_item == modsuit || part.part_item.loc != modsuit) && !part.sealed)
								sealed = FALSE
								break
						if(!sealed)
							break
					else
						break
			if(living.buckled)
				if(living.buckled.anchored)
					break
				else
					var/obj/buckled_obj = living.buckled
					buckled_obj.unbuckle_mob(living)
		if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_CLOSET) && iscloset(movable))
			break
		if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_MECH_EQUIPMENT) && istype(movable, /obj/item/mecha_parts/mecha_equipment))
			break
		if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_VEHICLE) && isvehicle(movable))
			var/obj/vehicle/vehicle = movable
			if(vehicle.is_occupant(teleportable))
				break
		if(!(container_flags & TELEPORT_CONTAINER_INCLUDE_STOMACH) && istype(movable, /obj/item/organ/stomach))
			var/obj/item/organ/stomach/stomach = movable
			if(teleportable in stomach.stomach_contents)
				break
		teleportable = movable
	return teleportable
