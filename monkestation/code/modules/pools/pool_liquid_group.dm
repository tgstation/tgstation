/datum/liquid_group/pool_group
	///list of all merger turfs, we can only spread in these turfs
	var/list/merger_turfs = list()
	///the connected pump used when new pumps try and attach
	var/obj/machinery/pool_pump/connected_pump
	///we do not evaporate
	evaporates = FALSE
	///we do not merge
	can_merge = FALSE
	///we lose way less liquids from applications
	loss_precent = 0.1

/datum/liquid_group/pool_group/Destroy()
	. = ..()
	for(var/turf/open/floor/lowered/iron/pool/pool_turf as anything in merger_turfs) /// pool is drained now we remove the pool references
		pool_turf.cached_group = null
	if(connected_pump)
		connected_pump.attached_group = null
		connected_pump = null

/datum/liquid_group/pool_group/spread_liquid(turf/new_turf, turf/source_turf)
	if(isclosedturf(new_turf) || !source_turf.atmos_adjacent_turfs)
		return
	if(!(new_turf in source_turf.atmos_adjacent_turfs)) //i hate that this is needed
		return
	if(!source_turf.atmos_adjacent_turfs[new_turf])
		return
	if(!istype(new_turf, /turf/open/floor/lowered/iron/pool))
		return

	if(!new_turf.liquids && !istype(new_turf, /turf/open/openspace) && !isspaceturf(new_turf) && !istype(new_turf, /turf/open/floor/plating/ocean) && source_turf.turf_height == new_turf.turf_height) // no space turfs, or oceans turfs, also don't attempt to spread onto a turf that already has liquids wastes processing time
		if(reagents_per_turf < LIQUID_HEIGHT_DIVISOR)
			return FALSE
		if(!length(members))
			return FALSE
		reagents_per_turf = total_reagent_volume / members.len
		expected_turf_height = CEILING(reagents_per_turf, 1) / LIQUID_HEIGHT_DIVISOR
		new_turf.liquids = new(new_turf, src)
		new_turf.liquids.alpha = group_alpha
		check_edges(new_turf)

		var/obj/splashy = new /obj/effect/temp_visual/liquid_splash(new_turf)
		if(new_turf.liquids.liquid_group)
			splashy.color = new_turf.liquids.liquid_group.group_color

		water_rush(new_turf, source_turf)

	return TRUE
