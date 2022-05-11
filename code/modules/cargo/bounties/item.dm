/datum/bounty/item
	///How many items have to be shipped to complete the bounty
	var/required_count = 1
	///How many items have been shipped for the bounty so far
	var/shipped_count = 0
	///Types accepted|denied by the bounty. (including all subtypes, unless include_subtypes is set to FALSE)
	var/list/wanted_types
	///Set to FALSE to make the bounty not accept subtypes of the wanted_types
	var/include_subtypes = TRUE

/datum/bounty/item/New()
	..()
	wanted_types = string_assoc_list(zebra_typecacheof(wanted_types, only_root_path = !include_subtypes))

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

/// If the user can actually get this bounty as a selection.
/datum/bounty/item/proc/can_get()
	return TRUE
