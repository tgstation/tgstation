SUBSYSTEM_DEF(liquids)
	name = "Liquid Turfs"
	wait = 0.5 SECONDS
	flags = SS_POST_FIRE_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/active_groups = list()

	var/list/evaporation_queue = list()
	var/evaporation_counter = 0 //Only process evaporation on intervals

	var/list/temperature_queue = list()

	var/list/active_ocean_turfs = list()
	var/list/ocean_turfs = list()
	var/list/currentrun_active_ocean_turfs = list()
	var/list/unvalidated_oceans = list()
	var/ocean_counter = 0

	var/run_type = SSLIQUIDS_RUN_TYPE_GROUPS

	///debug variable to toggle evaporation from running
	var/debug_evaporation = FALSE

	var/list/burning_turfs = list()
	var/fire_counter = 0

	var/member_counter = 0

	var/list/arrayed_groups = list()


/datum/controller/subsystem/liquids/stat_entry(msg)
	msg += "AG:[active_groups.len]|BT:[burning_turfs.len]|EQ:[evaporation_queue.len]|AO:[active_ocean_turfs.len]|UO:[length(unvalidated_oceans)]"
	return ..()

/datum/controller/subsystem/liquids/fire(resumed)
	if(!active_groups.len && !evaporation_queue.len && !active_ocean_turfs.len && !burning_turfs.len && !unvalidated_oceans.len)
		return

	if(length(unvalidated_oceans))
		for(var/turf/open/floor/plating/ocean/unvalidated_turf in unvalidated_oceans)
			if(MC_TICK_CHECK)
				return
			unvalidated_turf.assume_self()

	if(length(arrayed_groups))
		for(var/g in arrayed_groups)
			var/datum/liquid_group/LG = g
			if(!LG)
				arrayed_groups -= g
				continue
			while(!MC_TICK_CHECK && length(LG.splitting_array)) // three at a time until we either finish or over-run, this should be done before anything else
				LG.work_on_split_queue()
				LG.cleanse_members()

	if(!length(temperature_queue))
		for(var/g in active_groups)
			if(MC_TICK_CHECK)
				return
			var/datum/liquid_group/LG = g
			var/list/turfs = LG.fetch_temperature_queue()
			temperature_queue += turfs

	if(run_type == SSLIQUIDS_RUN_TYPE_GROUPS)
		if(active_groups.len)
			var/populate_evaporation = FALSE
			if(!evaporation_queue.len)
				populate_evaporation = TRUE
			for(var/g in active_groups)
				if(MC_TICK_CHECK)
					return
				var/datum/liquid_group/LG = g

				LG.build_turf_reagent()
				LG.process_cached_edges()
				LG.process_group(TRUE)
				if(populate_evaporation && LG.expected_turf_height < LIQUID_STATE_ANKLES && LG.evaporates)
					for(var/tur in LG.members)
						var/turf/listed_turf = tur
						evaporation_queue |= listed_turf

		run_type = SSLIQUIDS_RUN_TYPE_TEMPERATURE

	if(run_type == SSLIQUIDS_RUN_TYPE_TEMPERATURE)
		if(temperature_queue.len)
			for(var/tur in temperature_queue)
				if(MC_TICK_CHECK)
					return
				var/turf/open/temperature_turf = tur
				temperature_queue -= temperature_turf
				if(!temperature_turf.liquids)
					continue
				if(!temperature_turf.liquids.liquid_group)
					qdel(temperature_turf.liquids)
					continue
				temperature_turf.liquids.liquid_group.act_on_queue(temperature_turf)
		run_type = SSLIQUIDS_RUN_TYPE_EVAPORATION

	if(run_type == SSLIQUIDS_RUN_TYPE_EVAPORATION && !debug_evaporation)
		evaporation_counter++
		if(evaporation_counter >= REQUIRED_EVAPORATION_PROCESSES)
			evaporation_counter = 0
			for(var/g in active_groups)
				if(MC_TICK_CHECK)
					return
				var/datum/liquid_group/LG = g
				LG.check_dead()
				if(!length(LG.splitting_array))
					LG.process_turf_disperse()
			for(var/t in evaporation_queue)
				if(MC_TICK_CHECK)
					return
				if(!prob(EVAPORATION_CHANCE))
					evaporation_queue -= t
					continue
				var/turf/T = t
				if(T.liquids)
					T.liquids.process_evaporation()
		run_type = SSLIQUIDS_RUN_TYPE_FIRE

	if(run_type == SSLIQUIDS_RUN_TYPE_FIRE)
		fire_counter++
		for(var/g in active_groups)
			if(MC_TICK_CHECK)
				return
			var/datum/liquid_group/LG = g
			if(LG.burning_members.len)
				for(var/turf/burning_turf in LG.burning_members)
					if(MC_TICK_CHECK)
						return
					LG.process_spread(burning_turf)

		if(fire_counter > REQUIRED_FIRE_PROCESSES)
			for(var/g in active_groups)
				if(MC_TICK_CHECK)
					return
				var/datum/liquid_group/LG = g
				if(LG.burning_members.len)
					LG.process_fire()
			fire_counter = 0
		run_type = SSLIQUIDS_RUN_TYPE_OCEAN

	if(!currentrun_active_ocean_turfs.len)
		currentrun_active_ocean_turfs = active_ocean_turfs

	if(run_type == SSLIQUIDS_RUN_TYPE_OCEAN)
		ocean_counter++
		if(ocean_counter >= REQUIRED_OCEAN_PROCESSES)
			for(var/turf/open/floor/plating/ocean/active_ocean in currentrun_active_ocean_turfs)
				if(MC_TICK_CHECK)
					return
				active_ocean.process_turf()
			ocean_counter = 0
		run_type = SSLIQUIDS_RUN_TYPE_TURFS

	if(run_type == SSLIQUIDS_RUN_TYPE_TURFS)
		member_counter++
		if(member_counter > REQUIRED_MEMBER_PROCESSES)
			for(var/g in active_groups)
				if(MC_TICK_CHECK)
					return
				var/datum/liquid_group/LG = g
				LG.build_turf_reagent()
				if(!LG.exposure)
					continue
				for(var/turf/member in LG.members)
					if(MC_TICK_CHECK)
						return
					LG.process_member(member)
			member_counter = 0
		run_type = SSLIQUIDS_RUN_TYPE_GROUPS


/client/proc/toggle_liquid_debug()
	set category = "Debug"
	set name = "Liquid Groups Color Debug"
	set desc = "Liquid Groups Color Debug."
	if(!holder)
		return
	GLOB.liquid_debug_colors = !GLOB.liquid_debug_colors
