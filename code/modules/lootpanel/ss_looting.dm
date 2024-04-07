
/// Slow search
PROCESSING_SUBSYSTEM_DEF(looting)
	name = "Loot Panel Search"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 2 SECONDS


/**
 * The intent of this is to iterate over the contents and find invalid items or items that still need icons.
 * It runs normally until its out of icons, but the user can restart the process which will prune invalid
 */
/datum/lootpanel/process(seconds_per_tick)
	var/datum/tgui/panel = SStgui.get_open_ui(user, src)
	if(isnull(panel))
		reset()
		return PROCESS_KILL

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile) || !user.Adjacent(tile))
		reset()
		return PROCESS_KILL

	var/current = 0
	for(var/ref in contents)
		if(current == search_speed)
			panel.send_update()
			return

		var/datum/search_object/obj = contents[ref]

		var/atom/thing  = obj.item_ref?.resolve()
		if(isnull(thing) || !user.Adjacent(thing) || !locate(thing) in tile.contents)
			contents -= ref
			continue

		if(obj.icon)
			continue

		if(!obj.generate_icon())
			contents -= ref
			continue

		current++

	searching = FALSE
	panel.send_update()	
	return PROCESS_KILL
