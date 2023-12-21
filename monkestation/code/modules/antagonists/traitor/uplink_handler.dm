/datum/uplink_handler
	/// Extra stuff that cannot be purchased by an uplink, regardless of flag.
	var/list/locked_entries = list()

///Add items to our locked_entries
/datum/uplink_handler/proc/add_locked_entries(list/items_to_add)
	for(var/datum/uplink_item/item as anything in items_to_add)
		locked_entries |= item
