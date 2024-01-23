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

/**
 * Change the size of the storage item to match the inserted item's
 * Because of that, we also check if conditions to keep it inside another storage or pockets are still met.
 */
/datum/storage/fish_case/handle_enter(obj/item/storage/fish_case/source, obj/item/arrived)
	. = ..()
	if(!istype(arrived) || arrived.w_class <= source.w_class)
		return
	source.w_class = arrived.w_class
	// melbert todo : general solution for this
	// Since we're changing weight class we need to check if our storage's loc's storage can still hold us
	if(!isnull(real_location.loc.atom_storage) && !real_location.loc.atom_storage.can_insert(source))
		source.forceMove(real_location.loc.drop_location())
		source.visible_message(span_warning("[source] spills out of [real_location.loc] as it expands to hold [arrived]!"), vision_distance = 1)

	else if(!isliving(source.loc))
		return

	var/mob/living/living_loc = source.loc
	if((living_loc.get_slot_by_item(source) & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && source.w_class > WEIGHT_CLASS_SMALL)
		source.forceMove(living_loc.drop_location())
		to_chat(living_loc, span_warning("[source] drops out of your pockets as it expands to hold [arrived]!"))

/datum/storage/fish_case/handle_exit(obj/item/storage/fish_case/source, obj/item/gone)
	. = ..()
	if(istype(gone))
		source.w_class = initial(source.w_class)
