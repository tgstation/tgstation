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
	var/static/list/delete_atoms = typecacheof(
		list(
			/obj/effect = TRUE,
			/obj/effect/dummy/chameleon = FALSE,
			/obj/effect/wisp = FALSE,
			/obj/effect/mob_spawn = FALSE,
			/obj/effect/immovablerod = FALSE,
		),
		zebra = TRUE
	)
	if(delete_atoms[teleatom.type])
		qdel(teleatom)
		return FALSE

	// argument handling
	// if the precision is not specified, default to 0, but apply BoH penalties
	if (isnull(precision))
		precision = 0

	SEND_SIGNAL(teleatom, COMSIG_MOVABLE_TELEPORTED, destination, channel)

	switch(channel)
		if(TELEPORT_CHANNEL_BLUESPACE)
			if(istype(teleatom, /obj/item/storage/backpack/holding))
				precision = rand(1,100)

			var/static/list/bag_cache = typecacheof(/obj/item/storage/backpack/holding)
			var/list/bagholding = typecache_filter_list(teleatom.get_all_contents(), bag_cache)
			if(bagholding.len)
				precision = max(rand(1,100)*bagholding.len,100)
				if(isliving(teleatom))
					var/mob/living/MM = teleatom
					to_chat(MM, span_warning("The bluespace interface on your bag of holding interferes with the teleport!"))

			// if effects are not specified and not explicitly disabled, sparks
			if ((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/spark_spread/sparks = new
				sparks.set_up(5, 1, teleatom)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks
		if(TELEPORT_CHANNEL_QUANTUM)
			// if effects are not specified and not explicitly disabled, rainbow sparks
			if ((!effectin || !effectout) && !no_effects)
				var/datum/effect_system/spark_spread/quantum/sparks = new
				sparks.set_up(5, 1, teleatom)
				if (!effectin)
					effectin = sparks
				if (!effectout)
					effectout = sparks

	// perform the teleport
	var/turf/curturf = get_turf(teleatom)
	var/turf/destturf = get_teleport_turf(get_turf(destination), precision)

	if(!destturf || !curturf || destturf.is_transition_turf())
		return FALSE

	var/area/A = get_area(curturf)
	var/area/B = get_area(destturf)
	if(!forced && (HAS_TRAIT(teleatom, TRAIT_NO_TELEPORT) || (A.area_flags & NOTELEPORT) || (B.area_flags & NOTELEPORT)))
		return FALSE

	if(SEND_SIGNAL(destturf, COMSIG_ATOM_INTERCEPT_TELEPORT, channel, curturf, destturf))
		return FALSE

	if(isobserver(teleatom))
		teleatom.abstract_move(destturf)
		return TRUE

	tele_play_specials(teleatom, curturf, effectin, asoundin)
	var/success = teleatom.forceMove(destturf)
	if(success)
		log_game("[key_name(teleatom)] has teleported from [loc_name(curturf)] to [loc_name(destturf)]")
		tele_play_specials(teleatom, destturf, effectout, asoundout)

	if(ismob(teleatom))
		var/mob/M = teleatom
		M.cancel_camera()

	return TRUE

/proc/tele_play_specials(atom/movable/teleatom, atom/location, datum/effect_system/effect, sound)
	if(!location)
		return

	if(sound)
		playsound(location, sound, 60, TRUE)
	if(effect)
		effect.attach(location)
		effect.start()

// Safe location finder
/proc/find_safe_turf(zlevel, list/zlevels, extended_safety_checks = FALSE, dense_atoms = TRUE)
	if(!zlevels)
		if (zlevel)
			zlevels = list(zlevel)
		else
			zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/cycles = 1000
	for(var/cycle in 1 to cycles)
		// DRUNK DIALLING WOOOOOOOOO
		var/x = rand(1, world.maxx)
		var/y = rand(1, world.maxy)
		var/z = pick(zlevels)
		var/random_location = locate(x,y,z)

		if(is_safe_turf(random_location, extended_safety_checks, dense_atoms, cycle < 300))//if the area is mostly NOTELEPORT (centcom) we gotta give up on this fantasy at some point.
			return random_location

/// Checks if a given turf is a "safe" location
/proc/is_safe_turf(turf/random_location, extended_safety_checks = FALSE, dense_atoms = TRUE, no_teleport = FALSE)
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
	var/trace_gases
	for(var/id in floor_gases)
		if(id in GLOB.hardcoded_gases)
			continue
		trace_gases = TRUE
		break

	// Can most things breathe?
	if(trace_gases)
		return
	if(!(floor_gases[/datum/gas/oxygen] && floor_gases[/datum/gas/oxygen][MOLES] >= 16))
		return
	if(floor_gases[/datum/gas/plasma])
		return
	if(floor_gases[/datum/gas/carbon_dioxide] && floor_gases[/datum/gas/carbon_dioxide][MOLES] >= 10)
		return

	// Aim for goldilocks temperatures and pressure
	if((floor_gas_mixture.temperature <= 270) || (floor_gas_mixture.temperature >= 360))
		return
	var/pressure = floor_gas_mixture.return_pressure()
	if((pressure <= 20) || (pressure >= 550))
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

/proc/get_teleport_turfs(turf/center, precision = 0)
	if(!precision)
		return list(center)
	var/list/posturfs = list()
	for(var/turf/T as anything in RANGE_TURFS(precision,center))
		if(T.is_transition_turf())
			continue // Avoid picking these.
		var/area/A = T.loc
		if(!(A.area_flags & NOTELEPORT))
			posturfs.Add(T)
	return posturfs

/proc/get_teleport_turf(turf/center, precision = 0)
	var/list/turfs = get_teleport_turfs(center, precision)
	if (length(turfs))
		return pick(turfs)
