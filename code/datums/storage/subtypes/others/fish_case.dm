/datum/storage/fish_case
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	can_hold_description = "Fish and aquarium equipment"

/datum/storage/fish_case/can_insert(obj/item/to_insert, mob/user, messages, force)
	. = ..()
	if(!.)
		return

	if(!HAS_TRAIT(to_insert, TRAIT_AQUARIUM_CONTENT))
		if(messages && user)
			user.balloon_alert(user, "can't hold!")
		return FALSE
	return .

/datum/storage/fish_case/adjust_size

/*
 * Change the size of the storage item to match the inserted item's
 * Because of that, we also check if conditions to keep it inside another storage or pockets are still met.
 */
/datum/storage/fish_case/adjust_size/handle_enter(datum/source, obj/item/arrived)
	. = ..()
	if(!isitem(parent) || !istype(arrived))
		return
	var/obj/item/item_parent = parent
	if(arrived.w_class <= item_parent.w_class)
		return
	item_parent.update_weight_class(arrived.w_class)

/datum/storage/fish_case/adjust_size/handle_exit(datum/source, obj/item/gone)
	. = ..()
	if(!isitem(parent) || !istype(gone))
		return
	var/obj/item/item_parent = parent
	item_parent.update_weight_class(initial(item_parent.w_class))
