/datum/loadout_category/get_items()
	. = ..()
	for(var/datum/loadout_item/item as anything in .)
		if(item.is_available())
			continue
		. -= item
