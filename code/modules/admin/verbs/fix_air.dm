//Lifted 1:1 from Baystation
/client/proc/fixatmos()
	set category = "Admin"
	set name = "Fix Atmospherics Grief"

	if(!check_rights(R_ADMIN|R_DEBUG)) return

	if(alert("WARNING: Executing this command will perform a full reset of atmosphere. All pipelines will lose any gas that may be in them, and all zones will be reset to contain air mix as on roundstart. The supermatter engine will also be stopped (to prevent overheat due to removal of coolant). Do not use unless the map is suffering serious atmospheric issues due to grief or bug.", "Full Atmosphere Reboot", "No", "Yes") == "No")
		return
	if(!fix_atmos_grief())
		to_chat(world, span_danger("Atmospherics reboot failed!"))

/proc/fix_atmos_grief()
	log_admin("Full atmosphere reset initiated by [usr].")
	to_chat(world, "<span class = 'danger'>Initiating restart of atmosphere. The server may lag a bit.</span>")
	sleep(10)
	var/current_time = world.timeofday

	// Depower the supermatter, as it would quickly blow up once we remove all gases from the pipes.
	/*for(var/obj/machinery/power/supermatter_crystal/S in GLOB.machines)
		S.power = 0*/
	to_chat(usr, "\[1/5\] - Supermatter depowered")

	// Remove all gases from all pipenets
	for(var/datum/pipeline/PN as anything in SSairmachines.networks)
		for(var/datum/gas_mixture/G in list(PN.air) & PN.other_airs)
			G.gas = list()
			G.update_values()

	to_chat(usr, "\[2/5\] - All pipenets purged of gas.")

	// Delete all zones.
	for(var/zone/Z in world)
		Z.c_invalidate()

	to_chat(usr, "\[3/5\] - All ZAS Zones removed.")

	var/list/unsorted_overlays = list()
	for(var/id in xgm_gas_data.tile_overlay)
		unsorted_overlays |= xgm_gas_data.tile_overlay[id]

	//for(var/turf/simulated/T in world) ZASTURF
	for(var/turf/T in world)
		if(!T.simulated)
			continue
		T.air = null
		T.overlays.Remove(unsorted_overlays)
		T.zone = null

	to_chat(usr, "\[4/5\] - All turfs reset to roundstart values.")

	SSzas.Reboot()

	to_chat(usr, "\[5/5\] - ZAS Rebooted")
	to_chat(world, "<span class = 'danger'>Atmosphere restart completed in <b>[(world.timeofday - current_time)/10]</b> seconds.</span>")
	return TRUE
