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
	var/list/already_generated = list()
	var/static/list/preview_blacklist = list(
		/obj/machinery/computer,
		/obj/machinery/computer/old,
	)

	for(var/obj/typepath as anything in subtypesof(/obj))
		if(!initial(typepath.generate_map_preview))
			continue
		if(typepath in preview_blacklist)
			continue
		worklist += typepath

	var/turf/preview_turf = locate(1, 1, 1)

	var/filepath = "icons/obj/fluff/map_previews.dmi"
	var/icon/holder = icon('icons/obj/fluff/map_previews_template.dmi')

	for(var/path in worklist)
		var/obj/thingtospawn = new path(preview_turf)

		if(ismachinery(thingtospawn))
			var/obj/machinery/machine = thingtospawn
			machine.set_machine_stat(machine.machine_stat & ~NOPOWER)
			machine.update_appearance()

		var/key = "[thingtospawn.icon]-[thingtospawn.icon_state]"
		for(var/image/overlay as anything in thingtospawn.overlays)
			key += "-[overlay.icon_state]"
		if(already_generated[key])
			qdel(thingtospawn)
			continue
		already_generated[key] = TRUE

		var/icon_name = "[path]"
		for(var/dir in GLOB.cardinals)
			thingtospawn.setDir(dir)
			var/icon/rendered_icon = getFlatIcon(thingtospawn)
			if(!rendered_icon)
				continue
			var/icon/preview_frame = icon(rendered_icon, frame = 1)
			if(!preview_frame)
				continue
#ifdef UNIT_TESTS
			if(preview_frame.Width() > ICON_SIZE_X || preview_frame.Height() > ICON_SIZE_Y)
				stack_trace("Map preview generation for '[icon_name]' produced an icon larger than 32x32.")
				continue
#endif
			holder.Insert(preview_frame, icon_name, dir)
		qdel(thingtospawn)

	var/tmp_path = "tmp/map_previews.dmi"
	fcopy(holder, tmp_path)

	var/old_md5 = fexists(filepath) ? rustg_hash_file(RUSTG_HASH_MD5, filepath) : ""
	var/new_md5 = rustg_hash_file(RUSTG_HASH_MD5, tmp_path)
	if(old_md5 != new_md5)
		fcopy(tmp_path, filepath)
#ifdef UNIT_TESTS
		stack_trace("Generated map previews were different than what is currently saved. If you see this in a CI run it means you need to run the game once through initialization and commit the resulting file 'icons/obj/fluff/map_previews.dmi'.")
#endif
