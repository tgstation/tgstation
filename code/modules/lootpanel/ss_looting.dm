
/// Slow search
PROCESSING_SUBSYSTEM_DEF(looting)
	name = "Loot Panel Search"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.5 SECONDS


// Iterates over the tile contents for search objects without icons
/datum/lootpanel/process(seconds_per_tick)
	var/datum/tgui/panel = SStgui.get_open_ui(user, src)
	if(isnull(panel))
		stop_search()
		return PROCESS_KILL

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile) || !user.TurfAdjacent(tile))
		stop_search()
		return PROCESS_KILL

	var/processed = FALSE
	for(var/ref in contents)
		CHECK_TICK
		
		var/datum/search_object/obj = contents[ref]
		if(obj.icon)
			continue

		if(!obj.generate_icon())
			delete_search_object(obj)
			continue

		processed = TRUE

	if(processed)
		return

	searching = FALSE
	panel.send_update()	
	return PROCESS_KILL
