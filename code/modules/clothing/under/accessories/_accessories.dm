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
	slot_flags = NONE
	w_class = WEIGHT_CLASS_SMALL
	/// Whether or not the accessory displays through suits and the like.
	var/above_suit = TRUE
	/// TRUE if shown as a small icon in corner, FALSE if overlayed
	var/minimize_when_attached = TRUE
	/// What equipment slot the accessory attaches to.
	/// If NONE, can always attach, while if supplied, can only attach if the clothing covers this slot.
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
 * The accessory is not yet within the clothing's loc at this point, this hapens after success.
 */
/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	if(atom_storage)
		attach_to.clone_storage(atom_storage)
		attach_to.atom_storage.set_real_location(src)

	var/num_other_accessories = LAZYLEN(attach_to.attached_accessories)
	layer = FLOAT_LAYER + clamp(attach_to.max_number_of_accessories - num_other_accessories, 0, 10)
	plane = FLOAT_PLANE

	if(minimize_when_attached)
		transform *= 0.5
		// just randomize position
		pixel_x = 0 + rand(4, -4)
		pixel_y = 0 + rand(4, -4)

	RegisterSignal(attach_to, COMSIG_ITEM_EQUIPPED, PROC_REF(on_uniform_equipped))
	RegisterSignal(attach_to, COMSIG_ITEM_DROPPED, PROC_REF(on_uniform_dropped))
	RegisterSignal(attach_to, COMSIG_CLOTHING_UNDER_ADJUSTED, PROC_REF(on_uniform_adjusted))
	RegisterSignal(attach_to, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_uniform_update))

	var/mob/equipped_to = attach_to.loc
	if(istype(equipped_to))
		on_uniform_equipped(attach_to, equipped_to, equipped_to.get_slot_by_item(attach_to))

	return TRUE

/**
 * Detach this accessory from the passed clothing article
 *
 * We may have exited the clothing's loc at this point
 */
/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/detach_from)
	if(IS_WEAKREF_OF(src, detach_from.atom_storage?.real_location))
		// Ensure void items do not stick around
		atom_storage.close_all()
		detach_from.atom_storage.close_all()
		// And clean up the storage we made
		QDEL_NULL(detach_from.atom_storage)

	UnregisterSignal(detach_from, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_CLOTHING_UNDER_ADJUSTED, COMSIG_ATOM_UPDATE_OVERLAYS))
	var/mob/dropped_from = detach_from.loc
	if(istype(dropped_from))
		on_uniform_dropped(detach_from, dropped_from)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += (8 + LAZYLEN(detach_from.attached_accessories) * 2)

	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	return TRUE

/// Signal proc for [COMSIG_ITEM_EQUIPPED] on the uniform we're pinned to
/obj/item/clothing/accessory/proc/on_uniform_equipped(obj/item/clothing/under/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if(!(slot & source.slot_flags))
		return

	accessory_equipped(source, user)

/// Signal proc for [COMSIG_ITEM_DROPPED] on the uniform we're pinned to
/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/source, mob/living/user)
	SIGNAL_HANDLER

	accessory_dropped(source, user)
	user.update_clothing(ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)

/// Called when the uniform this accessory is pinned to is equipped in a valid slot
/obj/item/clothing/accessory/proc/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	return

/// Called when the uniform this accessory is pinned to is dropped
/obj/item/clothing/accessory/proc/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	return

/// Signal proc for [COMSIG_CLOTHING_UNDER_ADJUSTED] on the uniform we're pinned to
/// Checks if we can no longer be attached to the uniform, and if so, drops us
/obj/item/clothing/accessory/proc/on_uniform_adjusted(obj/item/clothing/under/source)
	SIGNAL_HANDLER

	if(can_attach_accessory(source))
		return

	source.remove_accessory(src)
	forceMove(source.drop_location())
	source.visible_message(span_warning("[src] falls off of [source]!"))

/// Signal proc for [COMSIG_ATOM_UPDATE_OVERLAYS] on the uniform we're pinned to to add our overlays to the inventory icon
/obj/item/clothing/accessory/proc/on_uniform_update(obj/item/source, list/overlays)
	SIGNAL_HANDLER

	overlays |= src

/obj/item/clothing/accessory/attack_self_secondary(mob/user)
	. = ..()
	if(.)
		return
	if(user.can_perform_action(src, NEED_DEXTERITY))
		above_suit = !above_suit
		to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")
		return TRUE

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += "It can be attached to a uniform. Alt-click to remove it once attached."
	. += "It can be worn above or below your suit. Right-click to toggle."
