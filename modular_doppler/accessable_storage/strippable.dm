#define TAIL_EQUIP_DELAY 2 SECONDS

/datum/strippable_item/mob_item_slot/tail
	key = STRIPPABLE_ITEM_TAIL

/datum/strippable_item/mob_item_slot/tail/should_show(atom/source, mob/user)
	if(!iscarbon(source))
		return FALSE
	var/mob/living/carbon/carbon_source = source
	var/obj/item/organ/external/tail/tail = carbon_source.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(!tail || !tail.atom_storage)
		return FALSE
	return TRUE

/datum/strippable_item/mob_item_slot/tail/get_item(atom/source)
	if(!iscarbon(source))
		return null
	var/mob/living/carbon/carbon_source = source
	var/obj/item/organ/external/tail/tail = carbon_source.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if(tail && tail.atom_storage && length(tail.contents))
		return tail.contents[1]

/datum/strippable_item/mob_item_slot/tail/try_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE
	if(equipping.w_class >= WEIGHT_CLASS_NORMAL)
		to_chat(user, span_warning("\The [equipping] is too big!"))
		return FALSE
	return TRUE

/datum/strippable_item/mob_item_slot/tail/start_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE
	if(!do_after(user, TAIL_EQUIP_DELAY, source))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(equipping))
		return FALSE
	return TRUE

/datum/strippable_item/mob_item_slot/tail/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!iscarbon(source))
		return FALSE
	var/mob/living/carbon/carbon_source = source
	var/obj/item/organ/external/tail/tail = carbon_source.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	tail.atom_storage?.attempt_insert(equipping, user)

	return finish_equip_mob(equipping, source, user)

/datum/strippable_item/mob_item_slot/tail/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE
	warn_owner(source)
	if(!do_after(user, TAIL_EQUIP_DELAY, source))
		return FALSE
	return TRUE

/datum/strippable_item/mob_item_slot/tail/proc/warn_owner(atom/owner)
	to_chat(owner, span_warning("You feel your tail being toyed with!"))

#undef TAIL_EQUIP_DELAY
