/// UI helper for converting the associative list to a list of lists
/datum/lootpanel/proc/get_contents()
	var/list/items = list()

	for(var/ref in contents)
		var/datum/search_object/item = contents[ref]
		if(!item.item_ref?.resolve())
			continue

		UNTYPED_LIST_ADD(items, list(
			"icon" = item.icon, 
			"name" = item.name, 
			"ref" = item.ref, 
		))
	
	return items


/// Grabs an object from the contents. Validates the object and the user
/datum/lootpanel/proc/grab(mob/user, ref)
	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile))
		return FALSE

	if(!user.Adjacent(tile))
		search_turf_ref = null
		reset()
		return FALSE

	var/datum/search_object/found_item = contents[ref]
	if(isnull(found_item))
		return FALSE
	
	var/atom/thing = found_item.item_ref?.resolve()	
	if(QDELETED(thing) || QDELETED(user))
		return FALSE

	if(!locate(thing) in tile.contents ||!thing.Adjacent(user))
		return FALSE

	if(!user.put_in_active_hand(thing))
		return FALSE

	qdel(found_item)
	contents -= ref
	current--
	total--

	return TRUE


/// Helper to open the panel
/datum/lootpanel/proc/open(mob/user, turf/tile)
	search_turf_ref = WEAKREF(tile)
	src.user = user
	total = length(tile.contents)

	start_search()
	ui_interact(user)


/// Helper for clearing the panel cache. "what the hell is going on" proc
/datum/lootpanel/proc/reset()
	QDEL_LIST(contents)
	searching = FALSE
	current = 0
	total = 0
	STOP_PROCESSING(SSlooting, src)


/// Search helper for finding all items in a slice. Returns a list
/datum/lootpanel/proc/search(list/slice)
	var/list/found = list()

	for(var/atom/thing as anything in slice)
		if(QDELETED(thing) || QDELETED(user) || !thing.Adjacent(user))
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


/// Helper for starting the search process
/datum/lootpanel/proc/start_search()
	QDEL_LIST(contents)
	current = 0
	searching = TRUE
	START_PROCESSING(SSlooting, src)
