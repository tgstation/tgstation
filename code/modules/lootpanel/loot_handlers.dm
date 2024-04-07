/// Item in the tile contents have been moved, update the loot panel if needed
/datum/lootpanel/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	var/ref = REF(source)
	if(isnull(contents[ref]))
		UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
		return

	var/datum/tgui/panel = SStgui.get_open_ui(usr, src)
	if(isnull(panel))
		UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
		reset()
		return

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile))
		UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
		reset()
		return

	if(!QDELETED(source) && get_turf(source) == tile)
		return

	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	contents -= ref
	panel.send_update()
