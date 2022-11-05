/**
 * Clothing accessories.
 *
 * These items can be slotted onto an undershirt to provide a bit of flair.
 *
 * These should be very light on their effects. Armor should be avoided entirely.
 *
 * Multiple accessories can be equipped on a mob, and only the firstmost one is shown on their sprite.
 * The rest are still shown on examine, but this may create unfair circumstances when you can't examine someone.
 */
/obj/item/clothing/accessory
	name = "Accessory"
	desc = "Something has gone wrong!"
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	icon_state = "plasma"
	inhand_icon_state = "" //no inhands
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	/// Whether or not the accessory displays through suits and the like.
	var/above_suit = TRUE
	/// TRUE if shown as a small icon in corner, FALSE if overlayed
	var/minimize_when_attached = TRUE
	/// What equipment slot the accessory attaches to.
	var/attachment_slot = CHEST

/**
 * Can we be attached to the passed clothing article?
 */
/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/attach_to, mob/living/user)
	if(!istype(attach_to))
		CRASH("[type] - can_attach_accessory called with an invalid item to attach to. (got: [attach_to])")

	if(atom_storage && attach_to.atom_storage)
		if(user)
			attach_to.balloon_alert(user, "isn't compatible!")
		return FALSE

	if(attachment_slot && !(attach_to.body_parts_covered & attachment_slot))
		if(user)
			attach_to.balloon_alert(user, "can't fit!")
		return FALSE

	return TRUE

/**
 * Actually attach this accessory to the passed clothing article.
 *
 * TODO: this is half handled in under/attach_accessory and half handled here. Pick a side!
 */
/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	if(atom_storage)
		attach_to.clone_storage(atom_storage)
		attach_to.atom_storage.set_real_location(src)

	var/num_other_accessories = LAZYLEN(attach_to.attached_accessories)
	layer = FLOAT_LAYER + clamp(attach_to.max_number_of_accessories - num_other_accessories, 0, 10)
	plane = FLOAT_PLANE

	if(minimize_when_attached)
		transform *= 0.5 //halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= (8 - (num_other_accessories * 2))

	// attach_to.add_overlay(src)
	attach_to.vis_contents |= src
	LAZYADD(attach_to.attached_accessories, src)
	forceMove(attach_to)

	/*
	if (islist(U.armor) || isnull(U.armor)) // This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor)) // we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)
	*/

	RegisterSignal(attach_to, COMSIG_ITEM_EQUIPPED, .proc/on_uniform_equipped)
	RegisterSignal(attach_to, COMSIG_ITEM_DROPPED, .proc/on_uniform_dropped)
	RegisterSignal(attach_to, COMSIG_CLOTHING_UNDER_ADJUSTED, .proc/on_uniform_adjusted)

	var/mob/equipped_to = attach_to.loc
	if(istype(equipped_to))
		on_uniform_equipped(attach_to, equipped_to, equipped_to.get_slot_by_item(attach_to))

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/detach_from)
	if(detach_from.atom_storage && IS_WEAKREF_OF(src, detach_from.atom_storage.real_location))
		QDEL_NULL(detach_from.atom_storage)

	/*
	U.armor = U.armor.detachArmor(armor)
	*/

	UnregisterSignal(detach_from, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_CLOTHING_UNDER_ADJUSTED))
	var/mob/dropped_from = detach_from.loc
	if(istype(dropped_from))
		on_uniform_dropped(detach_from, dropped_from)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += (8 + LAZYLEN(detach_from.attached_accessories) * 2)

	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	// detach_from.cut_overlays()
	detach_from.vis_contents -= src
	LAZYREMOVE(detach_from.attached_accessories, src)
	return TRUE

/obj/item/clothing/accessory/proc/on_uniform_equipped(obj/item/clothing/under/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if(!(slot & source.slot_flags))
		return

	accessory_equipped(source, user)

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/source, mob/living/user)
	SIGNAL_HANDLER

	accessory_dropped(source, user)
	user.update_clothing(ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)

/obj/item/clothing/accessory/proc/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	return

/obj/item/clothing/accessory/proc/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	return

/obj/item/clothing/accessory/proc/on_uniform_adjusted(obj/item/clothing/under/source)
	SIGNAL_HANDLER

	if(can_attach_accessory(source))
		return

	source.remove_accessory(src)
	forceMove(source.drop_location())
	source.visible_message(span_warning("[src] falls off of [source]!"))

/obj/item/clothing/accessory/attack_self_secondary(mob/user)
	if(user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = FALSE, need_hands = !iscyborg(user)))
		above_suit = !above_suit
		to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")
		return

	return ..()

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += "It can be attached to a uniform. Alt-click to remove it once attached."
	. += "It can be worn above or below your suit. Right-click to toggle."
