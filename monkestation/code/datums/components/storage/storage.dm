/datum/component/storage/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	. = ..()
	if (.)
		SEND_SIGNAL(parent, COMSIG_STORAGE_INSERTED, I, M)

/datum/component/storage/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	if (.)
		SEND_SIGNAL(parent, COMSIG_STORAGE_REMOVED, AM, new_location)

/datum/component/storage/proc/set_holdable(can_hold_list, cant_hold_list)
	if (can_hold_list != null)
		can_hold = typecacheof(can_hold_list)

	if (cant_hold_list != null)
		cant_hold = typecacheof(cant_hold_list)
