/datum/bounty/item
	///How many items have to be shipped to complete the bounty
	var/required_count = 1
	///How many items have been shipped for the bounty so far
	var/shipped_count = 0
	///Types accepted by the bounty (including all subtypes, unless include_subtypes is set to FALSE)
	var/list/wanted_types
	///Set to FALSE to make the bounty not accept subtypes of the wanted_types
	var/include_subtypes = TRUE
	///Types that should not be accepted by the bounty, also excluding all their subtypes
	var/list/exclude_types
	///Individual types that should be accepted even if their supertypes are excluded (yes, apparently this is necessary)
	var/list/special_include_types

/datum/bounty/item/New()
	..()
	wanted_types = typecacheof(wanted_types, only_root_path = !include_subtypes)
	if (exclude_types)
		exclude_types = string_assoc_list(typecacheof(exclude_types))
		for (var/e_type in exclude_types)
			wanted_types[e_type] = FALSE
	if (special_include_types)
		for (var/i_type in special_include_types)
			wanted_types[i_type] = TRUE
	wanted_types = string_assoc_list(wanted_types)

/datum/bounty/item/can_claim()
	return ..() && shipped_count >= required_count

/datum/bounty/item/applies_to(obj/O)
	if(!is_type_in_typecache(O, wanted_types))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return shipped_count < required_count

/datum/bounty/item/ship(obj/O)
	if(!applies_to(O))
		return
	if(istype(O,/obj/item/stack))
		var/obj/item/stack/O_is_a_stack = O
		shipped_count += O_is_a_stack.amount
	else
		shipped_count += 1
