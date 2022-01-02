/turf
	//used for temperature calculations
	var/thermal_conductivity = 0.05
	var/heat_capacity = INFINITY //This should be opt in rather then opt out
	var/temperature_archived

	///list of turfs adjacent to us that air can flow onto
	var/list/atmos_adjacent_turfs
	///bitfield of dirs in which we are superconducitng
	var/atmos_supeconductivity = NONE

	//used to determine whether we should archive
	var/archived_cycle = 0
	var/current_cycle = 0

	//used for mapping and for breathing while in walls (because that's a thing that needs to be accounted for...)
	//string parsed by /datum/gas/proc/copy_from_turf
	var/initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	//approximation of MOLES_O2STANDARD and MOLES_N2STANDARD pending byond allowing constant expressions to be embedded in constant strings
	// If someone will place 0 of some gas there, SHIT WILL BREAK. Do not do that.

/turf/open
	//used for spacewind
	var/pressure_difference = 0
	var/pressure_direction = 0

	var/datum/excited_group/excited_group
	var/excited = FALSE
	var/datum/gas_mixture/turf/air

	var/obj/effect/hotspot/active_hotspot
	/// air will slowly revert to initial_gas_mix
	var/planetary_atmos = FALSE
	/// once our paired turfs are finished with all other shares, do one 100% share
	/// exists so things like space can ask to take 100% of a tile's gas
	var/run_later = FALSE

	var/list/atmos_overlay_types //gas IDs of current active gas overlays
	var/significant_share_ticker = 0
	#ifdef TRACK_MAX_SHARE
	var/max_share = 0
	#endif

/turf/open/Initialize()
	if(!blocks_air)
		air = new
		air.copy_from_turf(src)
		if(planetary_atmos)
			if(!SSair.planetary[initial_gas_mix])
				var/datum/gas_mixture/immutable/planetary/mix = new
				mix.parse_string_immutable(initial_gas_mix)
				SSair.planetary[initial_gas_mix] = mix
	. = ..()

/turf/open/Destroy()
	if(active_hotspot)
		QDEL_NULL(active_hotspot)
	// Adds the adjacent turfs to the current atmos processing
	for(var/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	return ..()

/////////////////GAS MIXTURE PROCS///////////////////

/turf/open/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	if(!giver)
		return FALSE
	air.merge(giver)
	update_visuals()
	air_update_turf(FALSE, FALSE)
	return TRUE

/turf/open/remove_air(amount)
	var/datum/gas_mixture/ours = return_air()
	var/datum/gas_mixture/removed = ours.remove(amount)
	update_visuals()
	air_update_turf(FALSE, FALSE)
	return removed

/turf/open/proc/copy_air_with_tile(turf/open/T)
	if(istype(T))
		air.copy_from(T.air)

/turf/open/proc/copy_air(datum/gas_mixture/copy)
	if(copy)
		air.copy_from(copy)

/turf/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/GM = new
	GM.copy_from_turf(src)
	return GM

/turf/open/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	return air

/turf/open/return_analyzable_air()
	return return_air()

/turf/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature >= heat_capacity || to_be_destroyed)

/turf/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(exposed_temperature >= heat_capacity)
		to_be_destroyed = TRUE
	if(to_be_destroyed && exposed_temperature >= max_fire_temperature_sustained)
		max_fire_temperature_sustained = min(exposed_temperature, max_fire_temperature_sustained + heat_capacity / 4) //Ramp up to 100% yeah?
	if(to_be_destroyed && !changing_turf)
		burn()

/turf/proc/burn()
	burn_tile()
	var/chance_of_deletion
	if (heat_capacity) //beware of division by zero
		chance_of_deletion = max_fire_temperature_sustained / heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
	else
		chance_of_deletion = 100
	if(prob(chance_of_deletion))
		Melt()
		max_fire_temperature_sustained = 0
	else
		to_be_destroyed = FALSE

/turf/open/burn()
	if(!active_hotspot) //Might not even be needed since excited groups are no longer cringe
		..()

/turf/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	atmos_expose(air, exposed_temperature)

/turf/open/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	SEND_SIGNAL(src, COMSIG_TURF_EXPOSE, air, exposed_temperature)
	check_atmos_process(src, air, exposed_temperature) //Manually do this to avoid needing to use elements, don't want 200 second atom init times

/turf/proc/archive()
	temperature_archived = temperature

/turf/open/archive()
	air.archive()
	archived_cycle = SSair.times_fired
	temperature_archived = temperature

/////////////////////////GAS OVERLAYS//////////////////////////////


/turf/open/proc/update_visuals()
	var/list/atmos_overlay_types = src.atmos_overlay_types // Cache for free performance

	if(!air) // 2019-05-14: was not able to get this path to fire in testing. Consider removing/looking at callers -Naksu
		if (atmos_overlay_types)
			for(var/overlay in atmos_overlay_types)
				vis_contents -= overlay
			src.atmos_overlay_types = null
		return

	var/list/gases = air.gases

	var/list/new_overlay_types
	GAS_OVERLAYS(gases, new_overlay_types)

	if (atmos_overlay_types)
		for(var/overlay in atmos_overlay_types-new_overlay_types) //doesn't remove overlays that would only be added
			vis_contents -= overlay

	if (length(new_overlay_types))
		if (atmos_overlay_types)
			vis_contents += new_overlay_types - atmos_overlay_types //don't add overlays that already exist
		else
			vis_contents += new_overlay_types

	UNSETEMPTY(new_overlay_types)
	src.atmos_overlay_types = new_overlay_types

/proc/typecache_of_gases_with_no_overlays()
	. = list()
	for (var/gastype in subtypesof(/datum/gas))
		var/datum/gas/gasvar = gastype
		if (!initial(gasvar.gas_overlay))
			.[gastype] = TRUE

/////////////////////////////SIMULATION///////////////////////////////////
#ifdef TRACK_MAX_SHARE
#define LAST_SHARE_CHECK \
	var/last_share = our_air.last_share;\
	max_share = max(last_share, max_share);\
	if(last_share > MINIMUM_AIR_TO_SUSPEND){\
		our_excited_group.reset_cooldowns();\
		cached_ticker = 0;\
		enemy_tile.significant_share_ticker = 0;\
	} else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE) {\
		our_excited_group.dismantle_cooldown = 0;\
		cached_ticker = 0;\
		enemy_tile.significant_share_ticker = 0;\
	}
#else
#define LAST_SHARE_CHECK \
	var/last_share = our_air.last_share;\
	if(last_share > MINIMUM_AIR_TO_SUSPEND){\
		our_excited_group.reset_cooldowns();\
		cached_ticker = 0;\
		enemy_tile.significant_share_ticker = 0;\
	} else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE) {\
		our_excited_group.dismantle_cooldown = 0;\
		cached_ticker = 0;\
		enemy_tile.significant_share_ticker = 0;\
	}
#endif
#ifdef TRACK_MAX_SHARE
#define PLANET_SHARE_CHECK \
	var/last_share = our_air.last_share;\
	max_share = max(last_share, max_share);\
	if(last_share > MINIMUM_AIR_TO_SUSPEND){\
		our_excited_group.reset_cooldowns();\
		cached_ticker = 0;\
	} else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE) {\
		our_excited_group.dismantle_cooldown = 0;\
		cached_ticker = 0;\
	}
#else
#define PLANET_SHARE_CHECK \
	var/last_share = our_air.last_share;\
	if(last_share > MINIMUM_AIR_TO_SUSPEND){\
		our_excited_group.reset_cooldowns();\
		cached_ticker = 0;\
	} else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE) {\
		our_excited_group.dismantle_cooldown = 0;\
		cached_ticker = 0;\
	}
#endif

/turf/proc/process_cell(fire_count)
	SSair.remove_from_active(src)

/turf/open/process_cell(fire_count)
	if(archived_cycle < fire_count) //archive self if not already done
		archive()

	current_cycle = fire_count
	var/cached_ticker = significant_share_ticker
	cached_ticker += 1

	//cache for sanic speed
	var/list/adjacent_turfs = atmos_adjacent_turfs
	var/datum/excited_group/our_excited_group = excited_group
	var/our_share_coeff = 1/(LAZYLEN(adjacent_turfs) + 1)

	var/datum/gas_mixture/our_air = air

	var/list/share_end

	#ifdef TRACK_MAX_SHARE
	max_share = 0 //Gotta reset our tracker
	#endif

	for(var/t in adjacent_turfs)
		var/turf/open/enemy_tile = t

		// This var is only rarely set, exists so turfs can request to share at the end of our sharing
		// We need this so we can assume share is communative, which we need to do to avoid a hellish amount of garbage_collect()s
		if(enemy_tile.run_later)
			LAZYADD(share_end, enemy_tile)

		if(fire_count <= enemy_tile.current_cycle)
			continue
		enemy_tile.archive()

	/******************* GROUP HANDLING START *****************************************************************/

		var/should_share_air = FALSE
		var/datum/gas_mixture/enemy_air = enemy_tile.air

		//cache for sanic speed
		var/datum/excited_group/enemy_excited_group = enemy_tile.excited_group
		//If we are both in an excited group, and they aren't the same, merge.
		//If we are both in an excited group, and you're active, share
		//If we pass compare, and if we're not already both in a group, lets join up
		//If we both pass compare, add to active and share
		if(our_excited_group && enemy_excited_group)
			if(our_excited_group != enemy_excited_group)
				//combine groups (this also handles updating the excited_group var of all involved turfs)
				our_excited_group.merge_groups(enemy_excited_group)
				our_excited_group = excited_group //update our cache
		if(our_excited_group && enemy_excited_group && enemy_tile.excited) //If you're both excited, no need to compare right?
			should_share_air = TRUE
		else if(our_air.compare(enemy_air)) //Lets see if you're up for it
			SSair.add_to_active(enemy_tile) //Add yourself young man
			var/datum/excited_group/EG = our_excited_group || enemy_excited_group || new
			if(!our_excited_group)
				EG.add_turf(src)
			if(!enemy_excited_group)
				EG.add_turf(enemy_tile)
			our_excited_group = excited_group
			should_share_air = TRUE

		//air sharing
		if(should_share_air)
			var/difference = our_air.share(enemy_air, our_share_coeff, 1 / (LAZYLEN(enemy_tile.atmos_adjacent_turfs) + 1))
			if(difference)
				if(difference > 0)
					consider_pressure_difference(enemy_tile, difference)
				else
					enemy_tile.consider_pressure_difference(src, -difference)
			//This acts effectivly as a very slow timer, the max deltas of the group will slowly lower until it breaksdown, they then pop up a bit, and fall back down until irrelevant
			LAST_SHARE_CHECK


	/******************* GROUP HANDLING FINISH *********************************************************************/

	if (planetary_atmos) //share our air with the "atmosphere" "above" the turf
		var/datum/gas_mixture/G = SSair.planetary[initial_gas_mix]
		// archive ourself again so we don't accidentally share more gas than we currently have
		archive()
		if(our_air.compare(G))
			if(!our_excited_group)
				var/datum/excited_group/EG = new
				EG.add_turf(src)
				our_excited_group = excited_group
			// shares 4/5 of our difference in moles with the atmosphere
			our_air.share(G, 0.8, 0.8)
			// temperature share with the atmosphere with an inflated heat capacity to simulate faster sharing with a large atmosphere
			our_air.temperature_share(G, OPEN_HEAT_TRANSFER_COEFFICIENT, G.temperature_archived, G.heat_capacity() * 5)
			G.garbage_collect()
			PLANET_SHARE_CHECK

	for(var/turf/open/enemy_tile as anything in share_end)
		var/datum/gas_mixture/enemy_mix = enemy_tile.air
		archive()
		if(!our_air.compare(enemy_mix))
			continue
		if(!our_excited_group)
			var/datum/excited_group/EG = new
			EG.add_turf(src)
			our_excited_group = excited_group
		// We share 100% of our mix in this step. Let's jive
		var/difference = our_air.share(enemy_mix, 1, 1)
		LAST_SHARE_CHECK
		if(!difference)
			continue
		if(difference > 0)
			consider_pressure_difference(enemy_tile, difference)
		else
			enemy_tile.consider_pressure_difference(src, difference)

	our_air.react(src)

	update_visuals()
	if(!consider_superconductivity(starting = TRUE) && !active_hotspot) //Might need to include the return of react() here
		if(!our_excited_group) //If nothing of interest is happening, kill the active turf
			SSair.remove_from_active(src) //This will kill any connected excited group, be careful (This broke atmos for 4 years)
		if(cached_ticker > EXCITED_GROUP_DISMANTLE_CYCLES) //If you're stalling out, take a rest
			SSair.sleep_active_turf(src)

	significant_share_ticker = cached_ticker //Save our changes
	temperature_expose(our_air, our_air.temperature)

//////////////////////////SPACEWIND/////////////////////////////

/turf/open/proc/consider_pressure_difference(turf/T, difference)
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = get_dir(src, T)
		pressure_difference = difference

/turf/open/proc/high_pressure_movements()
	var/atom/movable/M
	for(var/thing in src)
		M = thing
		if (!M.anchored && !M.pulledby && M.last_high_pressure_movement_air_cycle < SSair.times_fired)
			M.experience_pressure_difference(pressure_difference, pressure_direction)

/atom/movable/var/pressure_resistance = 10
/atom/movable/var/last_high_pressure_movement_air_cycle = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75
	var/max_force = sqrt(pressure_difference)*(MOVE_FORCE_DEFAULT / 5)
	set waitfor = FALSE
	var/move_prob = 100
	if (pressure_resistance > 0)
		move_prob = (pressure_difference/pressure_resistance*PROBABILITY_BASE_PRECENT)-PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if (move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired

///////////////////////////EXCITED GROUPS/////////////////////////////

/*
	I've got a problem with excited groups
	Adding tiles works out fine, but if you try and remove them, we get issues
	The main one is to do with how sleeping tiles are processed
	If a tile is sleeping, it is removed from the active turfs list and not processed at all
	The issue comes when we try and reform excited groups after a removal like this
	and the turfs just poof go fully to sleep.
	We solve this with excited group cleanup. See the documentation for more details.
*/
/datum/excited_group
	var/list/turf_list = list()
	var/breakdown_cooldown = 0
	var/dismantle_cooldown = 0
	var/should_display = FALSE
	var/display_id = 0
	var/static/wrapping_id = 0

/datum/excited_group/New()
	SSair.excited_groups += src

/datum/excited_group/proc/add_turf(turf/open/T)
	turf_list += T
	T.excited_group = src
	dismantle_cooldown = 0
	if(should_display || SSair.display_all_groups)
		display_turf(T)

/datum/excited_group/proc/merge_groups(datum/excited_group/E)
	if(turf_list.len > E.turf_list.len)
		SSair.excited_groups -= E
		for(var/t in E.turf_list)
			var/turf/open/T = t
			T.excited_group = src
			turf_list += T
		should_display = E.should_display | should_display
		if(should_display || SSair.display_all_groups)
			E.hide_turfs()
			display_turfs()
		breakdown_cooldown = min(breakdown_cooldown, E.breakdown_cooldown) //Take the smaller of the two options
		dismantle_cooldown = 0
	else
		SSair.excited_groups -= src
		for(var/t in turf_list)
			var/turf/open/T = t
			T.excited_group = E
			E.turf_list += T
		E.should_display = E.should_display | should_display
		if(E.should_display || SSair.display_all_groups)
			hide_turfs()
			E.display_turfs()
		E.breakdown_cooldown = min(breakdown_cooldown, E.breakdown_cooldown)
		E.dismantle_cooldown = 0

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0
	dismantle_cooldown = 0

/datum/excited_group/proc/self_breakdown(roundstart = FALSE, poke_turfs = FALSE)
	var/datum/gas_mixture/A = new

	//make local for sanic speed
	var/list/A_gases = A.gases
	var/list/turf_list = src.turf_list
	var/turflen = turf_list.len
	var/imumutable_in_group = FALSE
	var/energy = 0
	var/heat_cap = 0

	for(var/t in turf_list)
		var/turf/open/T = t
		//Cache?
		var/datum/gas_mixture/turf/mix = T.air
		if (roundstart && istype(T.air, /datum/gas_mixture/immutable))
			imumutable_in_group = TRUE
			A.copy_from(T.air) //This had better be immutable young man
			A_gases = A.gases //update the cache
			break
		//"borrowing" this code from merge(), I need to play with the temp portion. Lets expand it out
		//temperature = (giver.temperature * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity
		var/capacity = mix.heat_capacity()
		energy += mix.temperature * capacity
		heat_cap += capacity

		var/list/giver_gases = mix.gases
		for(var/giver_id in giver_gases)
			ASSERT_GAS(giver_id, A)
			A_gases[giver_id][MOLES] += giver_gases[giver_id][MOLES]

	if(!imumutable_in_group)
		A.temperature = energy / heat_cap
		for(var/id in A_gases)
			A_gases[id][MOLES] /= turflen
		A.garbage_collect()

	for(var/t in turf_list)
		var/turf/open/T = t
		if(T.planetary_atmos) //We do this as a hack to try and minimize unneeded excited group spread over planetary turfs
			T.air.copy_from(SSair.planetary[T.initial_gas_mix]) //Comes with a cost of "slower" drains, but it's worth it
		else
			T.air.copy_from(A) //Otherwise just set the mix to a copy of our equalized mix
		T.update_visuals()
		if(poke_turfs) //Because we only activate all these once every breakdown, in event of lag due to this code and slow space + vent things, increase the wait time for breakdowns
			SSair.add_to_active(T)
			T.significant_share_ticker = EXCITED_GROUP_DISMANTLE_CYCLES //Max out the ticker, if they don't share next tick, nuke em

	breakdown_cooldown = 0

///Dismantles the excited group, puts allll the turfs to sleep
/datum/excited_group/proc/dismantle()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited = FALSE
		T.significant_share_ticker = 0
		SSair.active_turfs -= T
		#ifdef VISUALIZE_ACTIVE_TURFS //Use this when you want details about how the turfs are moving, display_all_groups should work for normal operation
		T.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_VIBRANT_LIME)
		#endif
	garbage_collect()

//Breaks down the excited group, this doesn't sleep the turfs mind, just removes them from the group
/datum/excited_group/proc/garbage_collect()
	if(display_id) //If we ever did make those changes
		hide_turfs()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited_group = null
	turf_list.Cut()
	SSair.excited_groups -= src
	if(SSair.currentpart == SSAIR_EXCITEDGROUPS)
		SSair.currentrun -= src

/datum/excited_group/proc/display_turfs()
	if(display_id == 0) //Hasn't been shown before
		wrapping_id = wrapping_id % GLOB.colored_turfs.len
		wrapping_id++ //We do this after because lists index at 1
		display_id = wrapping_id
	for(var/thing in turf_list)
		var/turf/display = thing
		display.vis_contents += GLOB.colored_turfs[display_id]

/datum/excited_group/proc/hide_turfs()
	for(var/thing in turf_list)
		var/turf/display = thing
		display.vis_contents -= GLOB.colored_turfs[display_id]
	display_id = 0

/datum/excited_group/proc/display_turf(turf/thing)
	if(display_id == 0) //Hasn't been shown before
		wrapping_id = wrapping_id % GLOB.colored_turfs.len
		wrapping_id++ //We do this after because lists index at 1
		display_id = wrapping_id
	thing.vis_contents += GLOB.colored_turfs[display_id]

////////////////////////SUPERCONDUCTIVITY/////////////////////////////

/**
ALLLLLLLLLLLLLLLLLLLLRIGHT HERE WE GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

Read the code for more details, but first, a brief concept discussion/area

Our goal here is to "model" heat moving through solid objects, so walls, windows, and sometimes doors.
We do this by heating up the floor itself with the heat of the gasmix ontop of it, this is what the coeffs are for here, they slow that movement
Then we go through the process below.

If an active turf is fitting, we add it to processing, conduct with any covered tiles, (read windows and sometimes walls)
Then we space some of our heat, and think about if we should stop conducting.
**/

/turf/proc/conductivity_directions()
	if(archived_cycle < SSair.times_fired)
		archive()
	return ALL_CARDINALS

///Returns a set of directions that we should be conducting in, NOTE, atmos_supeconductivity is ACTUALLY inversed, don't worrry about it
/turf/open/conductivity_directions()
	if(blocks_air)
		return ..()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!(T in atmos_adjacent_turfs) && !(atmos_supeconductivity & direction))
			. |= direction

///These two procs are a bit of a web, I belive in you
/turf/proc/neighbor_conduct_with_src(turf/open/other)
	if(!other.blocks_air) //Solid but neighbor is open
		other.temperature_share_open_to_solid(src)
	else //Both tiles are solid
		other.share_temperature_mutual_solid(src, thermal_conductivity)
	temperature_expose(null, temperature)

/turf/open/neighbor_conduct_with_src(turf/other)
	if(blocks_air)
		..()
		return

	if(!other.blocks_air) //Both tiles are open
		var/turf/open/T = other
		T.air.temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
	else //Open but neighbor is solid
		temperature_share_open_to_solid(other)
	SSair.add_to_active(src)

/turf/proc/super_conduct()
	var/conductivity_directions = conductivity_directions()

	if(conductivity_directions)
		//Conduct with tiles around me
		for(var/direction in GLOB.cardinals)
			if(conductivity_directions & direction)
				var/turf/neighbor = get_step(src,direction)

				if(!neighbor.thermal_conductivity)
					continue

				if(neighbor.archived_cycle < SSair.times_fired)
					neighbor.archive()

				neighbor.neighbor_conduct_with_src(src)

				neighbor.consider_superconductivity()

	radiate_to_spess()

	finish_superconduction()

/turf/proc/finish_superconduction(temp = temperature)
	//Make sure still hot enough to continue conducting heat
	if(temp < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
		SSair.active_super_conductivity -= src
		return FALSE

/turf/open/finish_superconduction()
	//Conduct with air on my tile if I have it
	if(!blocks_air)
		temperature = air.temperature_share(null, thermal_conductivity, temperature, heat_capacity)
	..((blocks_air ? temperature : air.temperature))

///Should we attempt to superconduct?
/turf/proc/consider_superconductivity(starting)
	if(!thermal_conductivity)
		return FALSE

	SSair.active_super_conductivity |= src
	return TRUE

/turf/open/consider_superconductivity(starting)
	if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	if(air.heat_capacity() < M_CELL_WITH_RATIO) // Was: MOLES_CELLSTANDARD*0.1*0.05 Since there are no variables here we can make this a constant.
		return FALSE
	return ..()

/turf/closed/consider_superconductivity(starting)
	if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	return ..()

/turf/proc/radiate_to_spess() //Radiate excess tile heat to space
	if(temperature > T0C) //Considering 0 degC as te break even point for radiation in and out
		var/delta_temperature = (temperature_archived - TCMB) //hardcoded space temperature
		if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

			var/heat = thermal_conductivity*delta_temperature* \
				(heat_capacity*HEAT_CAPACITY_VACUUM/(heat_capacity+HEAT_CAPACITY_VACUUM))
			temperature -= heat/heat_capacity

/turf/open/proc/temperature_share_open_to_solid(turf/sharer)
	sharer.temperature = air.temperature_share(null, sharer.thermal_conductivity, sharer.temperature, sharer.heat_capacity)

/turf/proc/share_temperature_mutual_solid(turf/sharer, conduction_coefficient) //This is all just heat sharing, don't get freaked out
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && heat_capacity && sharer.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity)) //The larger the combined capacity the less is shared

		temperature -= heat/heat_capacity //The higher your own heat cap the less heat you get from this arrangement
		sharer.temperature += heat/sharer.heat_capacity
