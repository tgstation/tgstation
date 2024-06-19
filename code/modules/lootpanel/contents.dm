/// Adds the item to contents and to_image (if needed)
/datum/lootpanel/proc/add_to_index(datum/search_object/index)
	RegisterSignal(index, COMSIG_QDELETING, PROC_REF(on_searchable_deleted))
	if(isnull(index.icon))
		to_image += index

	contents += index


/// Used to populate contents and start generating if needed
/datum/lootpanel/proc/populate_contents()
	if(length(contents))
		reset_contents()

	// Add source turf first
	var/datum/search_object/source = new(owner, source_turf)
	add_to_index(source)

	for(var/atom/thing as anything in source_turf.contents)
		// validate
		if(thing.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(thing.IsObscured())
			continue
		if(thing.invisibility > owner.mob.see_invisible)
			continue

		// convert
		var/datum/search_object/index = new(owner, thing)
		add_to_index(index)

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	window?.send_update()

	if(length(to_image))
		SSlooting.backlog += src


/// For: Resetting to empty. Ignores the searchable qdel event
/datum/lootpanel/proc/reset_contents()
	for(var/datum/search_object/index as anything in contents)
		contents -= index
		to_image -= index

		if(QDELETED(index))
			continue

		UnregisterSignal(index, COMSIG_QDELETING)
		qdel(index)
