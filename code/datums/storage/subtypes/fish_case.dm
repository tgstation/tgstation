/datum/storage/fish_case
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_HUGE
	can_hold_description = "Fish and aquarium equipment"

/datum/storage/fish_case/can_insert(obj/item/to_insert, mob/user, messages, force)
	. = ..()
	if(!.)
		return .
	if(!HAS_TRAIT(to_insert, TRAIT_FISH_CASE_COMPATIBILE))
		if(messages && user)
			user.balloon_alert(user, "can't hold!")
		return FALSE
	return .

/*
 * Change the size of the storage item to match the inserted item's
 * Because of that, we also check if conditions to keep it inside another storage or pockets are still met.
 */
/datum/storage/fish_case/handle_enter(datum/source, obj/item/arrived)
	. = ..()
	if(!isitem(parent) || !istype(arrived))
		return
	var/obj/item/item_parent = parent
	if(arrived.w_class <= item_parent.w_class)
		return
	item_parent.w_class = arrived.w_class
	// Since we're changing weight class we need to check if our storage's loc's storage can still hold us
	// in the future we need a generic solution to this to solve a bunch of other exploits
	var/datum/storage/loc_storage = item_parent.loc.atom_storage
	if(!isnull(loc_storage) && !loc_storage.can_insert(item_parent))
		item_parent.forceMove(item_parent.loc.drop_location())
		item_parent.visible_message(span_warning("[item_parent] spills out of [item_parent.loc] as it expands to hold [arrived]!"), vision_distance = 1)
		return

	if(isliving(item_parent.loc))
		var/mob/living/living_loc = item_parent.loc
		if((living_loc.get_slot_by_item(item_parent) & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && item_parent.w_class > WEIGHT_CLASS_SMALL)
			item_parent.forceMove(living_loc.drop_location())
			to_chat(living_loc, span_warning("[item_parent] drops out of your pockets as it expands to hold [arrived]!"))
		return

/datum/storage/fish_case/handle_exit(datum/source, obj/item/gone)
	. = ..()
	if(!isitem(parent) || !istype(gone))
		return
	var/obj/item/item_parent = parent
	item_parent.w_class = initial(item_parent.w_class)
