/**
	* # asset_cache_item
	* 
	* An internal datum containing info on items in the asset cache. Mainly used to cache md5 info for speed.
**/
/datum/asset_cache_item
	var/name
	var/md5
	var/resource

/datum/asset_cache_item/New(name, file)
	if (!isfile(file))
		file = fcopy_rsc(file)
	md5 = md5(file)
	if (!md5)
		md5 = md5(fcopy_rsc(file))
		if (!md5)
			CRASH("invalid asset sent to asset cache")
		debug_world_log("asset cache unexpected success of second fcopy_rsc")
	src.name = name
	resource = file
