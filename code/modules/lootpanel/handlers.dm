/// Item in the tile contents have been moved, update the loot panel if needed
/datum/lootpanel/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents(update = FALSE)
		return

	delete_search_object(contents[REF(source)])
	window.send_update()


/// The turf has been changed, update via callback
/datum/lootpanel/proc/on_tile_change(datum/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(src, PROC_REF(populate_contents))
