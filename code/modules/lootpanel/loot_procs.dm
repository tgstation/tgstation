/// Grabs an object from the contents
/datum/lootpanel/proc/grab(mob/user, ref)
	var/turf/tile = search_turf_ref?.resolve()
	if(isnull(tile))
		return FALSE

	var/atom/thing
	for(var/item in contents)
		if(item["ref"] == ref)
			thing = item
			break

	if(QDELETED(thing) || QDELETED(user))
		return FALSE

	if(!locate(thing) in tile.contents ||!thing.Adjacent(user))
		return FALSE

	if(!user.put_in_active_hand(thing))
		return FALSE

	contents -= thing
	return TRUE


/// Helper to open the panel
/datum/lootpanel/proc/open(mob/user, turf/tile)
	search_turf_ref = WEAKREF(tile)
	src.user = user
	total = length(tile.contents)

	start_search()
	ui_interact(user)


/// Helper for clearing the panel cache
/datum/lootpanel/proc/reset()
	contents.Cut()
	searching = FALSE
	search_turf_ref = null
	current = 0
	total = 0
	STOP_PROCESSING(SSlooting, src)


/// Search helper for finding all items in a slice. Returns a list
/datum/lootpanel/proc/search(list/slice)
	var/list/found = list()

	for(var/atom/thing as anything in slice)
		if(QDELETED(thing) || QDELETED(user) || !thing.Adjacent(user))
			continue

		var/string_icon
		if(ismob(thing) || length(thing.overlays) > 2)
			string_icon = costly_icon2html(thing, user_client, sourceonly = TRUE)
		else
			string_icon = icon2html(thing, user_client, sourceonly = TRUE)

		found += list(list(
			"icon" = string_icon,
			"name" = thing.name,
			"ref" = REF(thing),
		))

	return found


/// Helper for starting the search process
/datum/lootpanel/proc/start_search()
	contents.Cut()
	current = 0
	searching = TRUE
	START_PROCESSING(SSlooting, src)
