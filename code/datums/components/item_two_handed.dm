/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 *
 */
/datum/component/two_handed
	var/wielded = FALSE 			/// Are we holding the two handed item properly
	var/force_wielded = 0	 		/// Forces the item to be weilded
	var/force_unwielded = 0		 	/// Forces the item to be unweilded
	var/wieldsound = FALSE 			/// Play sound when wielded
	var/unwieldsound = FALSE 		/// Play sound when unwielded
	var/require_twohands = FALSE	/// Does it have to be held in both hands

/**
 * Two Handed component
 *
 * vars:
 * * require_twohands (optional) Does the item need both hands to be carried
 * * wieldsound (optional) The sound to play when wielded
 * * unwieldsound (optional) The sound to play when unwielded
 * * force_wielded (optional)
 * * force_unwielded (optional)
 */
/datum/component/two_handed/Initialize(require_twohands=FALSE, wieldsound=FALSE, unwieldsound=FALSE, force_wielded=0, force_unwielded=0)
	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/on_attack_self)

/// Triggered on equip of the item containing the component
/datum/component/two_handed/proc/on_equip(datum/source, mob/user, slot)
	if(require_twohands && slot == ITEM_SLOT_HANDS) // force equip the item
		wield(user)
	if(!user.is_holding(parent) && wielded && !require_twohands)
		unwield(user)

/// Triggered on drop of item containing the component
/datum/component/two_handed/proc/on_drop(datum/source, mob/user)
	if(require_twohands)
		unwield(user, show_message=TRUE)
	if(wielded)
		unwield(user)

/// Triggered on attack self of the item containing the component
/datum/component/two_handed/proc/on_attack_self(datum/source, mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/**
 * Wield the two handed item in both hands
 *
 * vars:
 * * user The mob/living/carbon that is wielding the item
 */
/datum/component/two_handed/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(ismonkey(user))
		to_chat(user, "<span class='warning'>It's too heavy for you to wield fully.</span>")
		return
	if(user.get_inactive_held_item())
		if(require_twohands)
			to_chat(user, "<span class='notice'>[parent] is too cumbersome to carry in one hand!</span>")
			user.dropItemToGround(parent, force=TRUE)
		else
			to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	if(user.get_num_arms() < 2)
		if(require_twohands)
			user.dropItemToGround(parent, force=TRUE)
		to_chat(user, "<span class='warning'>You don't have enough intact hands.</span>")
		return

	var/obj/item/parent_item = parent
	wielded = TRUE
	if(force_wielded)
		parent_item.force = force_wielded
	parent_item.name = "[parent_item.name] (Wielded)"
	parent_item.update_icon()

	if(iscyborg(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [parent] with both hands.</span>")

	// Play sound if one is set
	if (wieldsound)
		playsound(parent_item.loc, wieldsound, 50, TRUE)

	// Let's reserve the other hand
	var/obj/item/twohanded/offhand/offhand_item = new(user)
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	user.put_in_inactive_hand(offhand_item)

/**
 * icon_state support for icons using 0-1 for on off
 *
 * returns 0 or 1 Based on wielded state
 */
/datum/component/two_handed/proc/icon_state()
	return wielded ? 1 : 0

/**
 * Unwield the two handed item
 *
 * vars:
 * * user The mob/living/carbon that is unwielding the item
 * * show_message (option) show a message to chat on unwield
 */
/datum/component/two_handed/proc/unwield(mob/living/carbon/user, show_message=TRUE)
	if(!wielded || !user)
		return

	var/obj/item/parent_item = parent
	wielded = FALSE
	if(!force_unwielded)
		parent_item.force = force_unwielded

	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else // somethings wrong
		parent_item.name = "[initial(parent_item.name)]"
	parent_item.update_icon()

	// Update icons
	if(user.get_item_by_slot(ITEM_SLOT_BACK) == parent)
		user.update_inv_back()
	else
		user.update_inv_hands()

	// Show message if requested
	if(show_message)
		if(iscyborg(user))
			to_chat(user, "<span class='notice'>You free up your module.</span>")
		else if(require_twohands)
			to_chat(user, "<span class='notice'>You drop [parent].</span>")
		else
			to_chat(user, "<span class='notice'>You are now carrying [parent] with one hand.</span>")

	// Play sound if set
	if(unwieldsound)
		playsound(parent_item.loc, unwieldsound, 50, TRUE)

	// Remove the object in the offhand
	var/obj/item/twohanded/offhand/offhand_item = user.get_inactive_held_item()
	if(offhand_item && istype(offhand_item))
		offhand_item.unwield()

/**
 * The offhand dummy item for two handed items
 *
 */
/obj/item/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/wielded = FALSE // Off Hand tracking of wielded status

/obj/item/twohanded/offhand/Destroy()
	wielded = FALSE
	return ..()

// Only utilized by dismemberment since you can't normally switch to the offhand to drop it.
/obj/item/twohanded/offhand/dropped(mob/living/user, show_message=TRUE)
	SHOULD_CALL_PARENT(0)

	// Call the held object
	var/obj/item = user.get_active_held_item()
	if(item)
		if(comp_twohand)
			comp_twohand.unwield(user, show_message)
			// Drop item if off hand is dropped and the item requies both hands
			if(comp_twohand.require_twohands)
				user.dropItemToGround(item)

	// delete on drop
	if(!QDELETED(src))
		qdel(src)

/obj/item/twohanded/offhand/equipped(mob/user, slot)
	..()
	if(wielded && !user.is_holding(src) && !istype(src, /obj/item/twohanded/required))
		unwield(user)

/obj/item/twohanded/offhand/proc/unwield()
	if(wielded)
		wielded = FALSE
		qdel(src)

// You should never be able to do this in standard use of two handed items. This is a backup for lingering offhands.
/obj/item/twohanded/offhand/attack_self(mob/living/carbon/user)
	if (QDELETED(src))
		return
	// If you have a proper item in your other hand that the offhand is for, do nothing. This should never happen.
	var/obj/item/item = user.get_inactive_held_item()
	if (item && !istype(item, /obj/item/twohanded/offhand/))
		if(comp_twohand)
			return
	// If it's another offhand, or literally anything else, qdel.
	qdel(src)
