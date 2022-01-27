/datum/strippable_item/mob_item_slot/head
	key = STRIPPABLE_ITEM_HEAD
	item_slot = ITEM_SLOT_HEAD

/datum/strippable_item/mob_item_slot/back
	key = STRIPPABLE_ITEM_BACK
	item_slot = ITEM_SLOT_BACK

/datum/strippable_item/mob_item_slot/back/get_alternate_action(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/back/alternate_action(atom/source, mob/user)
	if(!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/mask
	key = STRIPPABLE_ITEM_MASK
	item_slot = ITEM_SLOT_MASK

/datum/strippable_item/mob_item_slot/neck
	key = STRIPPABLE_ITEM_NECK
	item_slot = ITEM_SLOT_NECK

/datum/strippable_item/mob_item_slot/handcuffs
	key = STRIPPABLE_ITEM_HANDCUFFS
	item_slot = ITEM_SLOT_HANDCUFFED

/datum/strippable_item/mob_item_slot/handcuffs/should_show(atom/source, mob/user)
	if (!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.handcuffed)

// You shouldn't be able to equip things to handcuff slots.
/datum/strippable_item/mob_item_slot/handcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/datum/strippable_item/mob_item_slot/legcuffs
	key = STRIPPABLE_ITEM_LEGCUFFS
	item_slot = ITEM_SLOT_LEGCUFFED

/datum/strippable_item/mob_item_slot/legcuffs/should_show(atom/source, mob/user)
	if (!iscarbon(source))
		return FALSE

	var/mob/living/carbon/carbon_source = source
	return !isnull(carbon_source.legcuffed)

// You shouldn't be able to equip things to legcuff slots.
/datum/strippable_item/mob_item_slot/legcuffs/try_equip(atom/source, obj/item/equipping, mob/user)
	return FALSE

/// A strippable item for a hand
/datum/strippable_item/hand
	// Putting dangerous clothing in our hand is fine.
	warn_dangerous_clothing = FALSE

	/// Which hand?
	var/hand_index

/datum/strippable_item/hand/get_item(atom/source)
	if (!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_for_held_index(hand_index)

/datum/strippable_item/hand/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if (!mob_source.can_put_in_hand(equipping, hand_index))
		to_chat(src, span_warning("\The [equipping] doesn't fit in that place!"))
		return FALSE

	return TRUE

/datum/strippable_item/hand/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return

	if (!ismob(source))
		return FALSE

	var/mob/mob_source = source

	if (!do_mob(user, source, equipping.equip_delay_other))
		return FALSE

	if (!mob_source.can_put_in_hand(equipping, hand_index))
		return FALSE

	if (!user.temporarilyRemoveItemFromInventory(equipping))
		return FALSE

	return TRUE

/datum/strippable_item/hand/finish_equip(atom/source, obj/item/equipping, mob/user)
	if (!iscarbon(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.put_in_hand(equipping, hand_index)

/datum/strippable_item/hand/start_unequip(atom/source, mob/user)
	. = ..()
	if (!.)
		return

	return start_unequip_mob(get_item(source), source, user)

/datum/strippable_item/hand/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	if (!ismob(source))
		return FALSE

	return finish_unequip_mob(item, source, user)

/datum/strippable_item/hand/left
	key = STRIPPABLE_ITEM_LHAND
	hand_index = 1

/datum/strippable_item/hand/right
	key = STRIPPABLE_ITEM_RHAND
	hand_index = 2
