// Loadout system. All items are children of /datum/gear. To make a new item, you usually just define a new item like /datum/gear/example
// then set required vars like name(string), category(slot define, take them from code/__DEFINES/inventory.dm (the lowertext ones) (be sure that there is an entry in
// slot_to_string(slot) proc in hippiestation/code/_HELPERS/mobs.dm to show the category name in preferences menu) and path (the actual item path).
// description defaults to the path initial desc, cost defaults to 1 point but if you think your item requires more points, the framework allows that
// and lastly, restricted_roles list allows you to let someone spawn with certain items only if the job they spawned with is on the list.

GLOBAL_LIST_EMPTY(loadout_items)

/proc/initialize_global_loadout_items()
	LAZYINITLIST(GLOB.loadout_items)
	for(var/item in subtypesof(/datum/gear))
		var/datum/gear/I = new item
		if(!GLOB.loadout_items[slot_to_string(I.category)])
			LAZYINITLIST(GLOB.loadout_items[slot_to_string(I.category)])
		LAZYSET(GLOB.loadout_items[slot_to_string(I.category)], I.name, I)


/datum/gear
	var/name
	var/category
	var/description
	var/path //item-to-spawn path
	var/cost = 1 //normally, each loadout costs a single point.
	var/list/restricted_roles

/datum/gear/New()
	..()
	if(!description && path)
		var/obj/O = path
		description = initial(O.desc)
