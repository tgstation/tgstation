/turf
	///used for temperature calculations in superconduction
	var/thermal_conductivity = 0.05
	///Amount of heat necessary to activate some atmos processes (there is a weird usage of this var because is compared directly to the temperature instead of heat energy)
	var/heat_capacity = INFINITY //This should be opt in rather then opt out
	///Archived version of the temperature on a turf
	var/temperature_archived
	///All currently stored conductivities changes
	var/list/thermal_conductivities

	///list of turfs adjacent to us that air can flow onto
	var/list/atmos_adjacent_turfs
	///bitfield of dirs in which we are superconducitng
	var/atmos_supeconductivity = NONE

	///used to determine whether we should archive
	var/archived_cycle = 0
	var/current_cycle = 0

	/**
	 * used for mapping and for breathing while in walls (because that's a thing that needs to be accounted for...)
	 * string parsed by /datum/gas/proc/copy_from_turf
	 * approximation of MOLES_O2STANDARD and MOLES_N2STANDARD pending byond allowing constant expressions to be embedded in constant strings
	 * If someone will place 0 of some gas there, SHIT WILL BREAK. Do not do that.
	**/
	var/initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open
	//used for spacewind
	///Pressure difference between two turfs
	var/pressure_difference = 0
	///Where the difference come from (from higher pressure to lower pressure)
	var/pressure_direction = 0

	///Excited group we are part of
	var/datum/excited_group/excited_group
	///Are we active?
	var/excited = FALSE
	///Our gas mix
	var/datum/gas_mixture/turf/air

	///If there is an active hotspot on us store a reference to it here
	var/obj/effect/hotspot/active_hotspot
	/// air will slowly revert to initial_gas_mix
	var/planetary_atmos = FALSE
	/// once our paired turfs are finished with all other shares, do one 100% share
	/// exists so things like space can ask to take 100% of a tile's gas
	var/run_later = FALSE

	///gas IDs of current active gas overlays
	var/list/atmos_overlay_types
	var/significant_share_ticker = 0
	#ifdef TRACK_MAX_SHARE
	var/max_share = 0
	#endif

/turf/open/Initialize(mapload)
	if(!blocks_air)
		air = create_gas_mixture()
		if(planetary_atmos)
			if(!SSair.planetary[initial_gas_mix])
				var/datum/gas_mixture/immutable/planetary/mix = new
				mix.parse_string_immutable(initial_gas_mix)
				SSair.planetary[initial_gas_mix] = mix
	return ..()

/turf/open/Destroy()
	if(active_hotspot)
		QDEL_NULL(active_hotspot)
	// Adds the adjacent turfs to the current atmos processing
	for(var/near_turf in atmos_adjacent_turfs)
		SSair.add_to_active(near_turf)
	return ..()

/////////////////GAS MIXTURE PROCS///////////////////

///Copies all gas info from the turf into a new gas_mixture, along with our temperature
///Returns the created gas_mixture
/turf/proc/create_gas_mixture()
	var/datum/gas_mixture/mix = SSair.parse_gas_string(initial_gas_mix, /datum/gas_mixture/turf)

	//acounts for changes in temperature
	var/turf/parent = parent_type
	if(temperature != initial(temperature) || temperature != initial(parent.temperature))
		mix.temperature = temperature

	return mix

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

/turf/open/proc/copy_air_with_tile(turf/open/target_turf)
	if(istype(target_turf))
		air.copy_from(target_turf.air)

/turf/open/proc/copy_air(datum/gas_mixture/copy)
	if(copy)
		air.copy_from(copy)

/turf/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/copied_mixture = create_gas_mixture()
	return copied_mixture

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
		burn_turf()

/turf/proc/burn_turf()
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

/turf/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	atmos_expose(air, exposed_temperature)

/turf/open/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	SEND_SIGNAL(src, COMSIG_TURF_EXPOSE, air, exposed_temperature)
	check_atmos_process(src, air, exposed_temperature) //Manually do this to avoid needing to use elements, don't want 200 second atom init times

/turf/proc/archive()
	temperature_archived = temperature

/turf/open/archive()
	LINDA_CYCLE_ARCHIVE(src)

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
	GAS_OVERLAYS(gases, new_overlay_types, src)

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
		LINDA_CYCLE_ARCHIVE(src)

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

	for(var/turf/open/enemy_tile as anything in adjacent_turfs)
		// This var is only rarely set, exists so turfs can request to share at the end of our sharing
		// We need this so we can assume share is communative, which we need to do to avoid a hellish amount of garbage_collect()s
		if(enemy_tile.run_later)
			LAZYADD(share_end, enemy_tile)

		if(fire_count <= enemy_tile.current_cycle)
			continue
		LINDA_CYCLE_ARCHIVE(enemy_tile)

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
			var/datum/excited_group/existing_group = our_excited_group || enemy_excited_group || new
			if(!our_excited_group)
				existing_group.add_turf(src)
			if(!enemy_excited_group)
				existing_group.add_turf(enemy_tile)
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
		var/datum/gas_mixture/planetary_mix = SSair.planetary[initial_gas_mix]
		// archive ourself again so we don't accidentally share more gas than we currently have
		LINDA_CYCLE_ARCHIVE(src)
		if(our_air.compare(planetary_mix))
			if(!our_excited_group)
				var/datum/excited_group/new_group = new
				new_group.add_turf(src)
				our_excited_group = excited_group
			// shares 4/5 of our difference in moles with the atmosphere
			our_air.share(planetary_mix, 0.8, 0.8)
			// temperature share with the atmosphere with an inflated heat capacity to simulate faster sharing with a large atmosphere
			our_air.temperature_share(planetary_mix, OPEN_HEAT_TRANSFER_COEFFICIENT, planetary_mix.temperature_archived, planetary_mix.heat_capacity() * 5)
			planetary_mix.garbage_collect()
			PLANET_SHARE_CHECK

	for(var/turf/open/enemy_tile as anything in share_end)
		var/datum/gas_mixture/enemy_mix = enemy_tile.air
		archive()
		// We share 100% of our mix in this step. Let's jive
		var/difference = our_air.share(enemy_mix, 1, 1)
		LAST_SHARE_CHECK
		if(!difference)
			continue
		if(difference > 0)
			consider_pressure_difference(enemy_tile, difference)
		else
			enemy_tile.consider_pressure_difference(src, difference)

	var/reacting = our_air.react(src)
	if(our_excited_group)
		our_excited_group.turf_reactions |= reacting //Adds the flag to turf_reactions so excited groups can check for them before dismantling.

	update_visuals()
	if(!consider_superconductivity(starting = TRUE) && !active_hotspot && !(reacting & (REACTING | STOP_REACTIONS)))
		if(!our_excited_group) //If nothing of interest is happening, kill the active turf
			SSair.remove_from_active(src) //This will kill any connected excited group, be careful (This broke atmos for 4 years)
		if(cached_ticker > EXCITED_GROUP_DISMANTLE_CYCLES) //If you're stalling out, take a rest
			SSair.sleep_active_turf(src)

	significant_share_ticker = cached_ticker //Save our changes
	temperature_expose(our_air, our_air.temperature)

//////////////////////////SPACEWIND/////////////////////////////

/turf/open/proc/consider_pressure_difference(turf/target_turf, difference)
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = get_dir(src, target_turf)
		pressure_difference = difference

/turf/open/proc/high_pressure_movements()
	var/atom/movable/moving_atom
	for(var/thing in src)
		moving_atom = thing
		if (!moving_atom.anchored && !moving_atom.pulledby && moving_atom.last_high_pressure_movement_air_cycle < SSair.times_fired)
			moving_atom.experience_pressure_difference(pressure_difference, pressure_direction)

/atom/movable
	///How much delta pressure is needed for us to move
	var/pressure_resistance = 10
	var/last_high_pressure_movement_air_cycle = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	set waitfor = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_PRE_PRESSURE_PUSH) & COMSIG_ATOM_BLOCKS_PRESSURE)
		return
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75
	var/max_force = sqrt(pressure_difference) * (MOVE_FORCE_DEFAULT / 5)
	var/move_prob = 100
	if (pressure_resistance > 0)
		move_prob = (pressure_difference / pressure_resistance * PROBABILITY_BASE_PRECENT) - PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if (move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired

///////////////////////////EXCITED GROUPS/////////////////////////////

/datum/excited_group
	///Stores a reference to the turfs we are controlling
	var/list/turf_list = list()
	///If this is over EXCITED_GROUP_BREAKDOWN_CYCLES we call self_breakdown()
	var/breakdown_cooldown = 0
	///If this is over EXCITED_GROUP_DISMANTLE_CYCLES we call dismantle()
	var/dismantle_cooldown = 0
	///Used for debug to show the excited groups active and their turfs
	var/should_display = FALSE
	///Id of the index color of the displayed group
	var/display_id = 0
	///Wrapping loop of the index colors
	var/static/wrapping_id = 0
	///All turf reaction flags we have received.
	var/turf_reactions = NONE

/datum/excited_group/New()
	SSair.excited_groups += src

/datum/excited_group/proc/add_turf(turf/open/target_turf)
	turf_list += target_turf
	target_turf.excited_group = src
	dismantle_cooldown = 0
	if(should_display || SSair.display_all_groups)
		display_turf(target_turf)

/datum/excited_group/proc/merge_groups(datum/excited_group/target_group)
	if(turf_list.len > target_group.turf_list.len)
		SSair.excited_groups -= target_group
		for(var/turf/open/group_member as anything in target_group.turf_list)
			group_member.excited_group = src
			turf_list += group_member
		should_display = target_group.should_display | should_display
		if(should_display || SSair.display_all_groups)
			target_group.hide_turfs()
			display_turfs()
		breakdown_cooldown = min(breakdown_cooldown, target_group.breakdown_cooldown) //Take the smaller of the two options
		dismantle_cooldown = 0
	else
		SSair.excited_groups -= src
		for(var/turf/open/group_member as anything in turf_list)
			group_member.excited_group = target_group
			target_group.turf_list += group_member
		target_group.should_display = target_group.should_display | should_display
		if(target_group.should_display || SSair.display_all_groups)
			hide_turfs()
			target_group.display_turfs()
		target_group.breakdown_cooldown = min(breakdown_cooldown, target_group.breakdown_cooldown)
		target_group.dismantle_cooldown = 0

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0
	dismantle_cooldown = 0

/datum/excited_group/proc/self_breakdown(roundstart = FALSE, poke_turfs = FALSE)
	var/datum/gas_mixture/shared_mix = new

	//make local for sanic speed
	var/list/shared_gases = shared_mix.gases
	var/list/turf_list = src.turf_list
	var/turflen = turf_list.len
	var/imumutable_in_group = FALSE
	var/energy = 0
	var/heat_cap = 0

	for(var/turf/open/group_member as anything in turf_list)
		//Cache?
		var/datum/gas_mixture/turf/mix = group_member.air
		if (roundstart)
			if(istype(group_member.air, /datum/gas_mixture/immutable))
				imumutable_in_group = TRUE
				shared_mix.copy_from(group_member.air) //This had better be immutable young man
				shared_gases = shared_mix.gases //update the cache
				break
			// If we're planetary use THAT mix, and stop here
			if(group_member.planetary_atmos)
				imumutable_in_group = TRUE
				var/datum/gas_mixture/planetary_mix = SSair.planetary[group_member.initial_gas_mix]
				shared_mix.copy_from(planetary_mix)
				shared_gases = shared_mix.gases // Cache update
				break
		//"borrowing" this code from merge(), I need to play with the temp portion. Lets expand it out
		//temperature = (giver.temperature * giver_heat_capacity + temperature * self_heat_capacity) / combined_heat_capacity
		var/capacity = mix.heat_capacity()
		energy += mix.temperature * capacity
		heat_cap += capacity

		var/list/giver_gases = mix.gases
		for(var/giver_id in giver_gases)
			ASSERT_GAS_IN_LIST(giver_id, shared_gases)
			shared_gases[giver_id][MOLES] += giver_gases[giver_id][MOLES]

	if(!imumutable_in_group)
		shared_mix.temperature = energy / heat_cap
		for(var/id in shared_gases)
			shared_gases[id][MOLES] /= turflen
		shared_mix.garbage_collect()

	for(var/turf/open/group_member as anything in turf_list)
		if(group_member.planetary_atmos) //We do this as a hack to try and minimize unneeded excited group spread over planetary turfs
			group_member.air.copy_from(SSair.planetary[group_member.initial_gas_mix]) //Comes with a cost of "slower" drains, but it's worth it
		else
			group_member.air.copy_from(shared_mix) //Otherwise just set the mix to a copy of our equalized mix
		group_member.update_visuals()
		if(poke_turfs) //Because we only activate all these once every breakdown, in event of lag due to this code and slow space + vent things, increase the wait time for breakdowns
			SSair.add_to_active(group_member)
			group_member.significant_share_ticker = EXCITED_GROUP_DISMANTLE_CYCLES //Max out the ticker, if they don't share next tick, nuke em

	breakdown_cooldown = 0

///Dismantles the excited group, puts allll the turfs to sleep
/datum/excited_group/proc/dismantle()
	for(var/turf/open/current_turf as anything in turf_list)
		current_turf.excited = FALSE
		current_turf.significant_share_ticker = 0
		SSair.active_turfs -= current_turf
		#ifdef VISUALIZE_ACTIVE_TURFS //Use this when you want details about how the turfs are moving, display_all_groups should work for normal operation
		current_turf.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_VIBRANT_LIME)
		#endif
	garbage_collect()

//Breaks down the excited group, this doesn't sleep the turfs mind, just removes them from the group
/datum/excited_group/proc/garbage_collect()
	if(display_id) //If we ever did make those changes
		hide_turfs()
	for(var/turf/open/current_turf as anything in turf_list)
		current_turf.excited_group = null
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
		var/offset = GET_Z_PLANE_OFFSET(display.z) + 1
		display.vis_contents += GLOB.colored_turfs[display_id][offset]

/datum/excited_group/proc/hide_turfs()
	for(var/thing in turf_list)
		var/turf/display = thing
		var/offset = GET_Z_PLANE_OFFSET(display.z) + 1
		display.vis_contents -= GLOB.colored_turfs[display_id][offset]
	display_id = 0

/datum/excited_group/proc/display_turf(turf/thing)
	if(display_id == 0) //Hasn't been shown before
		wrapping_id = wrapping_id % GLOB.colored_turfs.len
		wrapping_id++ //We do this after because lists index at 1
		display_id = wrapping_id
	var/offset = GET_Z_PLANE_OFFSET(thing.z) + 1
	thing.vis_contents += GLOB.colored_turfs[display_id][offset]

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
		var/turf/checked_turf = get_step(src, direction)
		if(!(checked_turf in atmos_adjacent_turfs) && !(atmos_supeconductivity & direction))
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
		return ..()

	if(!other.blocks_air) //Both tiles are open
		var/turf/open/open_other = other
		open_other.air.temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
	else //Open but neighbor is solid
		temperature_share_open_to_solid(other)
	SSair.add_to_active(src)

/turf/proc/super_conduct()
	var/conductivity_directions = conductivity_directions()

	if(conductivity_directions)
		//Conduct with tiles around me
		for(var/direction in GLOB.cardinals)
			if(!(conductivity_directions & direction))
				continue
			var/turf/neighbor = get_step(src, direction)

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

/// Radiate excess tile heat to space.
/turf/proc/radiate_to_spess()
	if(temperature <= T0C) // Considering 0 degC as the break even point for radiation in and out.
		return
	// Because we keep losing energy, makes more sense for us to be the T2 here.
	var/delta_temperature = temperature_archived - TCMB //hardcoded space temperature
	if(heat_capacity <= 0 || abs(delta_temperature) <= MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)
		return
	// Heat should be positive in most cases
	// coefficient applied first because some turfs have very big heat caps.
	var/heat = CALCULATE_CONDUCTION_ENERGY(thermal_conductivity * delta_temperature, HEAT_CAPACITY_VACUUM, heat_capacity)
	temperature -= heat / heat_capacity

/turf/open/proc/temperature_share_open_to_solid(turf/sharer)
	sharer.temperature = air.temperature_share(null, sharer.thermal_conductivity, sharer.temperature, sharer.heat_capacity)

/turf/proc/share_temperature_mutual_solid(turf/sharer, conduction_coefficient) //This is all just heat sharing, don't get freaked out
	var/delta_temperature = sharer.temperature_archived - temperature_archived
	if(abs(delta_temperature) <= MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER || !heat_capacity || !sharer.heat_capacity)
		return
	var/heat = conduction_coefficient * CALCULATE_CONDUCTION_ENERGY(delta_temperature, heat_capacity, sharer.heat_capacity)
	temperature += heat / heat_capacity //The higher your own heat cap the less heat you get from this arrangement
	sharer.temperature -= heat / sharer.heat_capacity

#undef LAST_SHARE_CHECK
#undef PLANET_SHARE_CHECK
