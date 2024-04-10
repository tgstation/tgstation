
/// Slow search
PROCESSING_SUBSYSTEM_DEF(looting)
	name = "Loot Panel Search"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 0.5 SECONDS


/**
 * The intent of this is to iterate over the contents and find invalid items or items that still need icons.
 * It runs normally until its out of icons, but the user can restart the process which will prune invalid
 */
/datum/lootpanel/process(seconds_per_tick)
	var/datum/tgui/panel = SStgui.get_open_ui(user, src)
	if(isnull(panel))
		stop_search()
		return PROCESS_KILL

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile) || !user.TurfAdjacent(tile))
		stop_search()
		return PROCESS_KILL

	var/throttle = 0
	for(var/ref in contents)
		if(throttle == search_speed)
			panel.send_update()
			CHECK_TICK
			return

		var/datum/search_object/obj = contents[ref]
		
		var/atom/thing  = obj.item_ref?.resolve()
		if(isnull(thing))
			stop_search()
			return

		// Our base turf
		if(isturf(thing))
			if(!user.TurfAdjacent(thing))
				stop_search()
				return
		else // it's an object inside the turf
			if(isnull(thing) || !locate(thing) in tile.contents)
				contents -= ref
				continue

		if(obj.icon)
			continue

		if(!obj.generate_icon())
			contents -= ref
			continue

		throttle++
		CHECK_TICK

	searching = FALSE
	panel.send_update()	
	return PROCESS_KILL
