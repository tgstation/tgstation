SUBSYSTEM_DEF(map_previews)
	name = "Map Previews"
	ss_flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/machines,
		/datum/controller/subsystem/mapping,
	)

/datum/controller/subsystem/map_previews/Initialize()
#ifndef UNIT_TESTS
	if(!CONFIG_GET(flag/generate_assets_in_init))
		return SS_INIT_SUCCESS
#endif
	generate_map_previews()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/map_previews/proc/generate_map_previews()
	var/list/worklist = list()

	for(var/path in subtypesof(/obj))
		var/obj/typepath = path
		if(!initial(typepath.generate_map_preview))
			continue
		worklist += path
	var/turf/preview_turf = locate(1, 1, 1)
	var/icon/holder = icon()
	for(var/path in worklist)
		var/obj/thingtospawn = new path(preview_turf)
		if(ismachinery(thingtospawn))
			var/obj/machinery/machine = thingtospawn
			machine.set_machine_stat(machine.machine_stat & ~NOPOWER)
			machine.update_appearance()
		var/path_name = "[path]"
		for(var/dir in GLOB.cardinals)
			thingtospawn.setDir(dir)
			var/icon/flat = icon(getFlatIcon(thingtospawn), frame = 1)
			holder.Insert(flat, path_name, dir)
		qdel(thingtospawn)
	var/filepath = "icons/obj/fluff/map_previews.dmi"
	fcopy(holder, filepath)
