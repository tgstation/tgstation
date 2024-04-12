/// Used to populate contents and start generating if needed
/datum/lootpanel/proc/populate_contents()
	if(length(contents))
		reset_contents()

	// Add source turf first
	var/datum/search_object/source = new(owner, source_turf)
	RegisterSignal(source_turf, COMSIG_TURF_CHANGE, PROC_REF(on_turf_change))
	contents[REF(source_turf)] = source

	for(var/atom/thing as anything in source_turf.contents)
		// validate
		if(thing.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(thing.IsObscured())
			continue
		if(thing.invisibility > owner.mob.see_invisible)
			continue

		var/ref = REF(thing)
		if(contents[ref])
			continue

		// convert
		RegisterSignals(thing, list(
			COMSIG_ITEM_PICKUP,
			COMSIG_MOVABLE_MOVED,
			COMSIG_QDELETING,
			), PROC_REF(on_item_moved))

		var/datum/search_object/index = new(owner, thing)

		// flag for processing
		if(!index.icon)
			to_image += index

		contents[ref] = index

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	window?.send_update()

	if(length(to_image))
		SSlooting.backlog += src

	return TRUE


/// For: Resetting to empty.
/datum/lootpanel/proc/reset_contents()
	for(var/ref in contents)
		var/datum/search_object/index = contents[ref]
		if(QDELETED(index))
			contents -= ref

		delete_search_object(index)
