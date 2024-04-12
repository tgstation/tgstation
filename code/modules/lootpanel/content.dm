/// Unregisters and deletes. Called by lootpanel itself
/datum/lootpanel/proc/delete_search_object(datum/search_object/item)
	unregister_searchable(item)
	UnregisterSignal(item, COMSIG_QDELETING) // dont want to trigger a loop
	qdel(item)


/// Used to populate contents and start searching. If theres icons needing generated, notifies sslooting
/datum/lootpanel/proc/populate_contents()
	if(length(contents) || searching)
		reset_contents(update = FALSE)

	var/datum/search_object/source = new(owner, source_turf)
	RegisterSignal(source_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	contents[source.string_ref] = source
	
	var/mob/user = owner.mob
	var/needs_processing = FALSE
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
		RegisterSignal(item, COMSIG_QDELETING, PROC_REF(on_searchable_deleted))

		if(!item.icon) // queue for image processing
			to_image += item
			needs_processing = TRUE

		contents[ref] = item

	searching = TRUE
	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	window?.send_update()

	if(needs_processing)
		SSlooting.backlog += src

	return TRUE


/// Used by SSlooting to process images from the to_image list. Returns whether it was successful
/datum/lootpanel/proc/process_images()
	for(var/datum/search_object/item as anything in to_image)
		if(QDELETED(item) || item.icon)
			to_image -= item
			continue
	
		var/atom/thing = item.item_ref?.resolve()
		if(QDELETED(thing))
			delete_search_object(item)
			to_image -= item
			continue

		if(!item.generate_icon())
			delete_search_object(item)

		to_image -= item
	
	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents(update = FALSE)
		return TRUE // just remove it from sslooting

	searching = FALSE
	window.send_update()

	return !!length(to_image)


/// Clears contents, stops searching, and updates the UI if needed.
/datum/lootpanel/proc/reset_contents(update = TRUE)
	searching = FALSE
	
	for(var/ref in contents)
		var/datum/search_object/item = contents[ref]
		if(isnull(item))
			contents -= ref
			continue

		delete_search_object(item)

	to_image.Cut()

	if(update)
		var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
		window?.send_update()
		

/// Unregisters signals and removes the search object from contents.
/datum/lootpanel/proc/unregister_searchable(datum/search_object/item)
	contents -= item.string_ref

	var/atom/thing = item.item_ref?.resolve()
	if(QDELETED(thing))
		return

	if(isturf(thing)) // Our base turf
		UnregisterSignal(thing, COMSIG_TURF_CHANGE)
	else // Anything else
		UnregisterSignal(thing, COMSIG_ITEM_PICKUP)
		UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(thing, COMSIG_QDELETING)
