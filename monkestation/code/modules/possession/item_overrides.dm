/obj/item/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(.)
		return
	if(!user)
		return
	if(anchored)
		return

	if(isbasicmob(user))
		var/mob/living/basic/true_user = user
		if(!true_user.dexterous)
			if (obj_flags & CAN_BE_HIT)
				return ..()
			return
	else if(istype(user, /mob/living/simple_animal))
		if(!user.dextrous)
			if (obj_flags & CAN_BE_HIT)
				return ..()
			return

	. = TRUE

	if(!(interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP)) //See if we're supposed to auto pickup.
		return

	//If the item is in a storage item, take it out
	if(loc.atom_storage && !loc.atom_storage.remove_single(user, src, user.loc, silent = TRUE))
		return
	if(QDELETED(src)) //moving it out of the storage to the floor destroyed it.
		return

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!allow_attack_hand_drop(user) || !user.temporarilyRemoveItemFromInventory(src))
			return

	. = FALSE
	if(cant_grab)
		return FALSE
	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)
		return TRUE
	return 0
