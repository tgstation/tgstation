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
			"icon_state" = item.icon_state,
			"icon" = item.icon,
			"name" = item.name, 
			"path" = item.path,
			"ref" = item.string_ref, 
		))
	
	return items


/// Grabs an object from the contents. Validates the object and the user
/datum/lootpanel/proc/grab(mob/user, list/params)
	var/ref = params["ref"]
	if(isnull(ref))
		return FALSE

	var/datum/search_object/obj = contents[ref]
	if(isnull(obj))
		return FALSE

	var/turf/source_tile = search_turf_ref?.resolve()
	if(isnull(source_tile))
		return FALSE

	if(!user.TurfAdjacent(source_tile))
		stop_search()
		return FALSE

	var/atom/thing = obj.item_ref?.resolve()	
	if(QDELETED(thing))
		return FALSE

	if(thing != source_tile && (!thing.Adjacent(user) || !locate(thing) in source_tile.contents))
		return FALSE

	var/modifiers = ""
	if(params["ctrl"])
		modifiers += "ctrl=1;"
	if(params["middle"])
		modifiers += "middle=1;"
	if(params["shift"])
		modifiers += "shift=1;"	

	user.ClickOn(thing, modifiers)

	return TRUE


/// Helper to open the panel
/datum/lootpanel/proc/open(mob/user, turf/tile)
	search_turf_ref = WEAKREF(tile)
	src.user = user

	if(!notified)
		if(build < 515 || (build == 515 && version < 1635))
			warn_image_generation()

	var/datum/tgui/open_window = SStgui.get_open_ui(user, src)
	if(open_window || searching)
		stop_search()

	RegisterSignal(tile, COMSIG_TURF_CHANGE, PROC_REF(on_tile_change), override = TRUE)
	start_search()
	ui_interact(user)


/// Helper for starting the search process. Dumps contents, validates tile, starts image processing
/datum/lootpanel/proc/start_search()
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

	var/datum/tgui/panel = SStgui.get_open_ui(user, src)
	if(isnull(panel))
		return

	panel.send_update()


/// Warns when a client does not support the fast 515 image generation.
/datum/lootpanel/proc/warn_image_generation()
	var/build = user_client.byond_build
	var/version = user_client.byond_version

	to_chat(user, examine_block(span_info("\
		<span class='bolddanger'>Your version of Byond doesn't support fast image loading.</span>\n\
		Detected: [version].[build]\n\
		Required version for this feature: <b>515.1635</b> or later.\n\
		Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.\n\
	")))

	notified = TRUE
