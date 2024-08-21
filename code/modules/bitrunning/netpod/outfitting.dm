/// Creates a list of outfit entries for the UI.
/obj/machinery/netpod/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/datum/outfit/outfit as anything in outfit_list)
		var/outfit_name = initial(outfit.name)
		if(findtext(outfit_name, "(") != 0 || findtext(outfit_name, "-") != 0) // No special variants please
			continue

		collection["outfits"] += list(list("path" = outfit, "name" = outfit_name))

	return list(collection)


/// Resolves a path to an outfit.
/obj/machinery/netpod/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(!ispath(path, /datum/outfit))
		return

	for(var/wardrobe in cached_outfits)
		for(var/outfit in wardrobe["outfits"])
			if(path == outfit["path"])
				return path

	message_admins("[usr]:[usr.ckey] attempted to select an unavailable outfit from a netpod")
	return
