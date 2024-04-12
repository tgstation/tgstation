/// Helper function for removing a search object. Takes a ref, finds it in contents.
/datum/lootpanel/proc/delete_search_object(datum/search_object/item)
	if(isnull(item))
		return

	contents -= item.string_ref

	var/atom/thing = item.item_ref?.resolve()
	if(QDELETED(thing))
		qdel(item)
		return

	if(isturf(thing)) // Our base turf
		UnregisterSignal(thing, COMSIG_TURF_CHANGE)
	else // Anything else
		UnregisterSignal(thing, COMSIG_ITEM_PICKUP)
		UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(thing, COMSIG_QDELETING)

	qdel(item)


/// Used to populate contents and start searching
/datum/lootpanel/proc/populate_contents()
	if(length(contents) || searching)
		reset_contents(update = FALSE)

	var/datum/search_object/source = new(owner, source_turf)
	contents[source.string_ref] = source
	
	var/mob/user = owner.mob
	for(var/atom/thing as anything in source_turf.contents)
		if(thing.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(thing.IsObscured())
			continue
		if(thing.invisibility > user.see_invisible)
			continue

		var/ref = REF(thing)
		if(contents[ref])
			continue

		RegisterSignals(thing, list(
			COMSIG_ITEM_PICKUP,
			COMSIG_MOVABLE_MOVED,
			COMSIG_QDELETING,
			), PROC_REF(on_item_moved))

		var/datum/search_object/item = new(owner, thing)
		contents[ref] = item

	searching = TRUE
	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	window?.send_update()
	START_PROCESSING(SSlooting, src)

	return TRUE


/// Clears contents, stops searching, and updates the UI if needed.
/datum/lootpanel/proc/reset_contents(update = TRUE)
	STOP_PROCESSING(SSlooting, src)
	searching = FALSE
	
	for(var/ref in contents)
		delete_search_object(contents[ref])

	if(update)
		var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
		window?.send_update()
