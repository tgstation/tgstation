// Its not full proof but it standerizes behavoir between gifts and lootboxes
/// Used for random item gen to try and generate a list of types that arent weird parent types and similar
/proc/get_sane_item_types(requested_type)
	if(!ispath(requested_type, /obj/item))
		return list()
	var/list/all_valid_types = list()
	for(var/obj/item/iter_type as anything in typesof(requested_type))
		if((iter_type.abstract_type == iter_type) || (iter_type.item_flags & ABSTRACT))
			continue
		if(iter_type.spawn_blacklisted)
			continue
		// The original behavior also included inhand icon states but that seems dumb
		// if(!iter_type.icon_state || !iter_type.inhand_icon_state)
		if(!iter_type.icon_state)
			continue // With the existance of abstract_type we could prob depricate this handling at some point
		all_valid_types += iter_type
	return all_valid_types
