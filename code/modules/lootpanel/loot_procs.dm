/// Converts the contents of the tile into search objects
/datum/lootpanel/proc/convert_tile_contents(list/slice)
	var/list/found = list()

	for(var/atom/thing as anything in slice)
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
			COMSIG_MOVABLE_MOVED,
			COMSIG_QDELETING,
			), PROC_REF(on_item_moved))

		var/datum/search_object/item = new(user, thing)
		found[ref] = item

	return found


/// Helper function for removing a search object
/datum/lootpanel/proc/delete_search_object(datum/search_object/item)
	contents -= item.string_ref
	qdel(item)


/// UI helper for converting the associative list to a list of lists
/datum/lootpanel/proc/get_contents()
	var/list/items = list()

	for(var/ref in contents)
		var/datum/search_object/item = contents[ref]
		if(!item.item_ref?.resolve())
			contents -= ref
			continue

		UNTYPED_LIST_ADD(items, list(
			"icon" = item.icon, 
			"name" = item.name, 
			"ref" = item.string_ref, 
		))
	
	return items


/// Grabs an object from the contents. Validates the object and the user
/datum/lootpanel/proc/grab(mob/user, list/params)
	var/ref = params["ref"]
	if(isnull(ref))
		return FALSE

	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile))
		return FALSE

	if(!user.TurfAdjacent(tile))
		stop_search()
		return FALSE

	var/datum/search_object/found_item = contents[ref]
	if(isnull(found_item))
		return FALSE
	
	var/atom/thing = found_item.item_ref?.resolve()	
	if(QDELETED(thing) || QDELETED(user))
		return FALSE

	if(!locate(thing) in tile.contents ||!thing.Adjacent(user))
		return FALSE

	var/modifiers = ""
	if(params["ctrl"])
		modifiers += "ctrl=1;"
	if(params["shift"])
		modifiers += "shift=1;"

	if(!user.ClickOn(thing, modifiers))
		return FALSE

	delete_search_object(found_item)

	return TRUE


/// Helper to open the panel
/datum/lootpanel/proc/open(mob/user, turf/tile)
	search_turf_ref = WEAKREF(tile)
	src.user = user

	RegisterSignal(tile, COMSIG_TURF_CHANGE, PROC_REF(on_tile_change))
	start_search()
	ui_interact(user)


/// Helper for starting the search process. Dumps contents, validates tile, starts image processing
/datum/lootpanel/proc/start_search()
	stop_search()

	var/turf/tile = search_turf_ref?.resolve()
	if(QDELETED(tile) || !user.TurfAdjacent(tile))
		return FALSE

	var/datum/search_object/source = new(user, tile)
	contents[source.string_ref] = source
	contents += convert_tile_contents(tile.contents)

	searching = TRUE
	START_PROCESSING(SSlooting, src)
	return TRUE


/// Helper for clearing the panel cache. "what the hell is going on" proc
/datum/lootpanel/proc/stop_search()
	STOP_PROCESSING(SSlooting, src)
	searching = FALSE
	
	for(var/ref in contents)
		var/datum/search_object/obj = contents[ref]

		var/atom/thing = obj.item_ref?.resolve()
		if(QDELETED(thing))
			delete_search_object(obj)
			continue

		if(isturf(thing)) // Our base turf
			UnregisterSignal(thing, COMSIG_TURF_CHANGE)
		else // Anything else
			if(!QDELETED(thing))
				UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
				UnregisterSignal(thing, COMSIG_QDELETING)

		delete_search_object(obj)
