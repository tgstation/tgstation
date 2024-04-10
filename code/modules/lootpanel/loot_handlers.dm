/// Item in the tile contents have been moved, update the loot panel if needed
/datum/lootpanel/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	var/ref = REF(source)
	if(isnull(contents[ref]))
		UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
		return

	var/datum/tgui/panel = SStgui.get_open_ui(usr, src)
	if(isnull(panel))
		stop_search()
		return

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile))
		stop_search()
		return

	if(!QDELETED(source) && get_turf(source) == tile)
		return

	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

	var/datum/search_object/found_item = contents[ref]
	delete_search_object(found_item)
	panel.send_update()


/// The turf has been changed, update via callback
/datum/lootpanel/proc/on_tile_change(datum/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	var/ref = REF(source)
	if(isnull(contents[ref]))
		stop_search()
		return

	post_change_callbacks += CALLBACK(src, PROC_REF(on_post_change))


/// Reset the search in case there were underlying items
/datum/lootpanel/proc/on_post_change(turf/new_tile)
	stop_search()
	search_turf_ref = WEAKREF(new_tile)
	start_search()
