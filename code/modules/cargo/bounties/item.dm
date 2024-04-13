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

/datum/bounty/item/applies_to(obj/shipped)
	if(!is_type_in_typecache(shipped, wanted_types))
		return FALSE
	if(shipped.flags_1 & HOLOGRAM_1)
		return FALSE
	return shipped_count < required_count

/datum/bounty/item/ship(obj/shipped)
	if(!applies_to(shipped))
		return FALSE
	if(istype(shipped,/obj/item/stack))
		var/obj/item/stack/shipped_is_a_stack = shipped
		shipped_count += shipped_is_a_stack.amount
	else
		shipped_count += 1
	return TRUE

/// If the user can actually get this bounty as a selection.
/datum/bounty/proc/can_get()
	return TRUE
