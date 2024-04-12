// Item in the tile contents have been moved, update.
/datum/lootpanel/proc/on_item_moved(atom/source)
	SIGNAL_HANDLER

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents(update = FALSE)
		return

	var/datum/search_object/item = contents[REF(source)]
	if(isnull(item))
		return
		
	delete_search_object(item)
	window.send_update()


/// The turf has been changed, update via callback
/datum/lootpanel/proc/on_turf_change(datum/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(src, PROC_REF(populate_contents))
