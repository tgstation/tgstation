// Loadout system. All items are children of /datum/gear. To make a new item, you usually just define a new item like /datum/gear/example
// then set required vars like name(string), category(slot define, take them from code/__DEFINES/inventory.dm (the lowertext ones) (be sure that there is an entry in
// slot_to_string(slot) proc in hippiestation/code/_HELPERS/mobs.dm to show the category name in preferences menu) and path (the actual item path).
// description defaults to the path initial desc, cost defaults to 1 point but if you think your item requires more points, the framework allows that
// and lastly, restricted_roles list allows you to let someone spawn with certain items only if the job they spawned with is on the list.

GLOBAL_LIST_EMPTY(loadout_items)
GLOBAL_LIST_EMPTY(loadout_whitelist_ids)

/proc/load_loadout_config(loadout_config)
	if(!loadout_config)
		loadout_config = "config/loadout_config.txt"
	LAZYINITLIST(GLOB.loadout_whitelist_ids)
	var/list/file_lines = world.file2list(loadout_config)
	for(var/line in file_lines)
		if(!line || findtextEx(line,"#",1,2))
			continue
		var/list/lineinfo = splittext(line, "|")
		var/lineID = lineinfo[1]
		for(var/subline in lineinfo)
			var/sublinetypedef = findtext(subline, "=")
			if(sublinetypedef)
				var/sublinetype = copytext(subline, 1, sublinetypedef)
				var/list/sublinecontent = splittext(copytext(subline, sublinetypedef+1), ",")
				if(sublinetype == "WHITELIST")
					GLOB.loadout_whitelist_ids["[lineID]"] = sublinecontent

/proc/initialize_global_loadout_items()
	LAZYINITLIST(GLOB.loadout_items)
	load_loadout_config()
	for(var/item in subtypesof(/datum/gear))
		var/datum/gear/I = new item
		if(!GLOB.loadout_items[slot_to_string(I.category)])
			LAZYINITLIST(GLOB.loadout_items[slot_to_string(I.category)])
		LAZYSET(GLOB.loadout_items[slot_to_string(I.category)], I.name, I)
		if(I.geargroupID in GLOB.loadout_whitelist_ids)
			I.ckeywhitelist = GLOB.loadout_whitelist_ids["[I.geargroupID]"]


/datum/gear
	var/name
	var/category
	var/description
	var/path //item-to-spawn path
	var/cost = 1 //normally, each loadout costs a single point.
	var/geargroupID //defines the ID that the gear inherits from the config
	var/list/restricted_roles
	var/list/ckeywhitelist

/datum/gear/New()
	..()
	if(!description && path)
		var/obj/O = path
		description = initial(O.desc)
