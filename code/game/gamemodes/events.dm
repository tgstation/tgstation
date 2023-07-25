/**
 * Causes a power failure across the station.
 *
 * All SMESs and APCs will be fully drained, and all areas will power down.
 *
 * The drain is permanent (that is, it won't automatically come back after some time like the grid check event),
 * but the crew themselves can return power via the engine, solars, or other means of creating power.
 */
/proc/power_failure()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", ANNOUNCER_POWEROFF)
	var/list/all_smes = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes)
	for(var/obj/machinery/power/smes/smes as anything in all_smes)
		if(istype(get_area(smes), /area/station/ai_monitored/turret_protected) || !is_station_level(smes.z))
			continue
		smes.charge = 0
		smes.output_level = 0
		smes.output_attempt = FALSE
		smes.update_appearance()
		smes.power_change()

	for(var/area/station_area as anything in GLOB.areas)
		if(!station_area.z || !is_station_level(station_area.z))
			continue
		if(!station_area.requires_power || station_area.always_unpowered )
			continue
		if(GLOB.typecache_powerfailure_safe_areas[station_area.type])
			continue

		station_area.power_light = FALSE
		station_area.power_equip = FALSE
		station_area.power_environ = FALSE
		station_area.power_change()

	for(var/obj/machinery/power/apc/C as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(C.cell && is_station_level(C.z))
			var/area/A = C.area
			if(GLOB.typecache_powerfailure_safe_areas[A.type])
				continue

			C.cell.charge = 0

/**
 * Restores power to all rooms on the station.
 *
 * Magically fills ALL APCs and SMESs to capacity, and restores power to depowered areas.
 */
/proc/power_restore()
	priority_announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", ANNOUNCER_POWERON)
	for(var/obj/machinery/power/apc/C as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(C.cell && is_station_level(C.z))
			C.cell.charge = C.cell.maxcharge
			COOLDOWN_RESET(C, failure_timer)
	var/list/all_smes = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes)
	for(var/obj/machinery/power/smes/smes as anything in all_smes)
		if(!is_station_level(smes.z))
			continue
		smes.charge = smes.capacity
		smes.output_level = smes.output_level_max
		smes.output_attempt = TRUE
		smes.update_appearance()
		smes.power_change()

	for(var/area/station_area as anything in GLOB.areas)
		if(!station_area.z || !is_station_level(station_area.z))
			continue
		if(!station_area.requires_power || station_area.always_unpowered)
			continue
		if(istype(station_area, /area/shuttle))
			continue
		station_area.power_light = TRUE
		station_area.power_equip = TRUE
		station_area.power_environ = TRUE
		station_area.power_change()

/**
 * A quicker version of [/proc/power_restore] that only handles recharging SMESs.
 *
 * This will also repower an entire station - it is not instantaneous like power restore,
 * but it is faster performance-wise as it only handles SMES units.
 *
 * Great as a less magical / more IC way to return power to a sapped station.
 */
/proc/power_restore_quick()
	priority_announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", ANNOUNCER_POWERON)
	var/list/all_smes = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/smes)
	for(var/obj/machinery/power/smes/smes as anything in all_smes)
		if(!is_station_level(smes.z))
			continue
		smes.charge = smes.capacity
		smes.output_level = smes.output_level_max
		smes.output_attempt = TRUE
		smes.update_appearance()
		smes.power_change()
