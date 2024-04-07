
/// Slow search
PROCESSING_SUBSYSTEM_DEF(looting)
	name = "Loot Panel Search"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS


/datum/lootpanel/process(seconds_per_tick)
	if(!searching)
		reset()
		return PROCESS_KILL

	var/turf/search_turf = search_turf_ref?.resolve()
	if(isnull(search_turf))
		reset()
		return PROCESS_KILL

	var/end = total - current > search_speed ? current + search_speed : 0
	var/list/slice_search = search_turf.contents.Copy(current + 1, end)

	contents += search(slice_search)

	var/datum/tgui/panel = SStgui.get_open_ui(user, src)
	if(isnull(panel))
		reset()
		return PROCESS_KILL

	panel.send_update()	
	current += length(slice_search)

	if(current < total)
		return

	searching = FALSE
	return PROCESS_KILL
