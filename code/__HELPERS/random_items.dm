// Its not full proof but it standerizes behavoir between gifts and lootboxes
/// Used for random item gen to try and generate a list of types that arent weird parent types and similar
/proc/generate_reasonable_types(requested_type)
	var/list/all_valid_types = list()
	for(var/obj/item/gun/iter_type as anything in typesof(requested_type))
		if(!iter_type:icon_state || !iter_type:inhand_icon_state)
			continue
		if((iter_type:item_flags & ABSTRACT) || iter_type:abstract_type == iter_type)
			continue
		if(iter_type:spawn_blacklisted)
			continue
		all_valid_types += iter_type
	return all_valid_types
