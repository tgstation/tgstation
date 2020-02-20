/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 *
 */
/datum/component/two_handed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS 		// Only one of the component can exist on an item
	var/wielded = FALSE 							/// Are we holding the two handed item properly
	var/force_wielded = 0	 						/// The force of the item when weilded
	var/force_unwielded = 0		 					/// The force of the item when unweilded
	var/wieldsound = FALSE 							/// Play sound when wielded
	var/unwieldsound = FALSE 						/// Play sound when unwielded
	var/require_twohands = FALSE					/// Does it have to be held in both hands
	var/datum/callback/icon_update_callback = null 	/// The proc to call on updating the icon
	var/datum/callback/on_wield_callback = null 	/// The proc to call on weld of the item
	var/datum/callback/on_unwield_callback = null 	/// The proc to call on unweld of the item

/**
 * Two Handed component
 *
 * vars:
 * * require_twohands (optional) Does the item need both hands to be carried
 * * wieldsound (optional) The sound to play when wielded
 * * unwieldsound (optional) The sound to play when unwielded
 * * force_wielded (optional) The force setting when the item is wielded
 * * force_unwielded (optional) The force setting when the item is unwielded
 * * icon_update_callback (optional) proc (wielded) Callback with wielded status
 * * on_wield_callback (optional) proc (user) Callback on wield of the item
 * * on_unwield_callback (optional) proc (user) Callback on unwield of the item
 */
/datum/component/two_handed/Initialize(require_twohands=FALSE, wieldsound=FALSE, unwieldsound=FALSE, force_wielded=0, force_unwielded=0, \
										datum/callback/icon_update_callback=null, datum/callback/on_wield_callback=null, datum/callback/on_unwield_callback=null)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded
	src.icon_update_callback = icon_update_callback
	src.on_wield_callback = on_wield_callback
	src.on_unwield_callback = on_unwield_callback

// Inherit the new values passed to the component
/datum/component/two_handed/InheritComponent(datum/component/two_handed/new_comp, original, require_twohands=FALSE, \
												wieldsound=FALSE, unwieldsound=FALSE, force_wielded=0, force_unwielded=0, \
												datum/callback/icon_update_callback=null, datum/callback/on_wield_callback=null, datum/callback/on_unwield_callback=null)
	if(!original)
		return
	if(new_comp)
		src.require_twohands = new_comp.require_twohands
		src.wieldsound = new_comp.wieldsound
		src.unwieldsound = new_comp.unwieldsound
		src.force_wielded = new_comp.force_wielded
		src.force_unwielded = new_comp.force_unwielded
		src.icon_update_callback = new_comp.icon_update_callback
		src.on_wield_callback = new_comp.on_wield_callback
		src.on_unwield_callback = new_comp.on_unwield_callback
	else
		src.require_twohands = require_twohands
		src.wieldsound = wieldsound
		src.unwieldsound = unwieldsound
		src.force_wielded = force_wielded
		src.force_unwielded = force_unwielded
		src.icon_update_callback = icon_update_callback
		src.on_wield_callback = on_wield_callback
		src.on_unwield_callback = on_unwield_callback

// register signals withthe parent item
/datum/component/two_handed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/on_attack_self)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, .proc/on_update_icon)
	RegisterSignal(parent, COMSIG_IS_TWOHANDED, .proc/on_check)
	RegisterSignal(parent, COMSIG_IS_TWOHANDED_WIELDED, .proc/is_wielded)
	RegisterSignal(parent, COMSIG_IS_TWOHANDED_REQUIRED, .proc/is_required)
	RegisterSignal(parent, COMSIG_TRY_TWOHANDED_WIELD, .proc/try_wield)
	RegisterSignal(parent, COMSIG_TRY_TWOHANDED_UNWIELD, .proc/try_unwield)
	RegisterSignal(parent, COMSIG_TWOHANDED_GET_FORCEWIELDED, .proc/get_force_wielded)
	RegisterSignal(parent, COMSIG_TWOHANDED_SET_FORCEWIELDED, .proc/set_force_wielded)
	RegisterSignal(parent, COMSIG_TWOHANDED_GET_FORCEUNWIELD, .proc/get_force_unwielded)
	RegisterSignal(parent, COMSIG_TWOHANDED_SET_FORCEUNWIELD, .proc/set_force_unwielded)

// Remove all siginals registered to the parent item
/datum/component/two_handed/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,
								COMSIG_ITEM_DROPPED,
								COMSIG_ITEM_ATTACK_SELF,
								COMSIG_ATOM_UPDATE_ICON,
								COMSIG_IS_TWOHANDED,
								COMSIG_IS_TWOHANDED_WIELDED,
								COMSIG_IS_TWOHANDED_REQUIRED,
								COMSIG_TRY_TWOHANDED_WIELD,
								COMSIG_TRY_TWOHANDED_UNWIELD,
								COMSIG_TWOHANDED_GET_FORCEWIELDED,
								COMSIG_TWOHANDED_SET_FORCEWIELDED,
								COMSIG_TWOHANDED_GET_FORCEUNWIELD,
								COMSIG_TWOHANDED_SET_FORCEUNWIELD))

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
	if(on_wield_callback)
		on_wield_callback.Invoke(user)
	if(force_wielded)
		parent_item.force = force_wielded
	parent_item.name = "[parent_item.name] (Wielded)"
	parent_item.update_icon()

	if(iscyborg(user))
		to_chat(user, "<span class='notice'>You dedicate your module to [parent].</span>")
	else
		to_chat(user, "<span class='notice'>You grab [parent] with both hands.</span>")

	// Play sound if one is set
	if(wieldsound)
		playsound(parent_item.loc, wieldsound, 50, TRUE)

	// Let's reserve the other hand
	var/obj/item/offhand/offhand_item = new(user)
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	user.put_in_inactive_hand(offhand_item)

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
	if(on_unwield_callback)
		on_unwield_callback.Invoke(user)
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
	var/obj/item/offhand/offhand_item = user.get_inactive_held_item()
	if(offhand_item && istype(offhand_item))
		offhand_item.unwield()

/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Invoikes the Icon Update Callback with wield status
 */
/datum/component/two_handed/proc/on_update_icon(datum/source)
	if(icon_update_callback)
		icon_update_callback.Invoke(wielded)

/**
 * is_wielded gets the current wield status of the component
 *
 * returns 0 or 1 Based on wielded state
 */
/datum/component/two_handed/proc/is_wielded(datum/source)
	return wielded

/**
 * on_check validates that the item has the component
 */
/datum/component/two_handed/proc/on_check(datum/source)
	return TRUE

/**
 * on_check validates that the item has the component
 */
/datum/component/two_handed/proc/is_required(datum/source)
	return require_twohands

/**
 * try_wield tries to wield the item
 */
/datum/component/two_handed/proc/try_wield(datum/source, mob/user)
	wield(user)
	return wielded

/**
 * try_unwield attempts to unwield the item
 */
/datum/component/two_handed/proc/try_unwield(datum/source, mob/user, show_message=TRUE)
	unwield(user, show_message)
	return wielded

/**
 * get_force_wielded returns int of the force_wielded
 */
/datum/component/two_handed/proc/get_force_wielded(datum/source)
	return force_wielded

/**
 * set_force_wielded Sets the value of force_wielded
 *
 * vars:
 * * force int The value to set force_wielded to
 */
/datum/component/two_handed/proc/set_force_wielded(datum/source, force)
	if(isnum(force))
		force_wielded = force

/**
 * get_force_unwielded returns int of the force_unwielded
 */
/datum/component/two_handed/proc/get_force_unwielded(datum/source)
	return force_unwielded

/**
 * set_force_unwielded Sets the value of force_unwielded
 *
 * vars:
 * * force int The value to set force_unwielded to
 */
/datum/component/two_handed/proc/set_force_unwielded(datum/source, force)
	if(isnum(force))
		force_unwielded = force

/**
 * The offhand dummy item for two handed items
 *
 */
/obj/item/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/wielded = FALSE // Off Hand tracking of wielded status

/obj/item/offhand/Destroy()
	wielded = FALSE
	return ..()

// Only utilized by dismemberment since you can't normally switch to the offhand to drop it.
/obj/item/offhand/dropped(mob/living/user, show_message=TRUE)
	SHOULD_CALL_PARENT(0)

	// Call the held object
	var/obj/item = user.get_active_held_item()
	if(item && SEND_SIGNAL(item, COMSIG_IS_TWOHANDED))
		SEND_SIGNAL(item, COMSIG_TRY_TWOHANDED_UNWIELD, user, show_message)
		// Drop item if off hand is dropped and the item requies both hands
		if(SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_REQUIRED))
			user.dropItemToGround(item)

	// delete on drop
	if(!QDELETED(src))
		qdel(src)

/obj/item/offhand/equipped(mob/user, slot)
	..()
	if(wielded && !user.is_holding(src) && !SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_REQUIRED))
		unwield(user)

/obj/item/offhand/proc/unwield()
	if(wielded)
		wielded = FALSE
		qdel(src)

// You should never be able to do this in standard use of two handed items. This is a backup for lingering offhands.
/obj/item/offhand/attack_self(mob/living/carbon/user)
	if (QDELETED(src))
		return
	// If you have a proper item in your other hand that the offhand is for, do nothing. This should never happen.
	var/obj/item/item = user.get_inactive_held_item()
	if (item && !istype(item, /obj/item/offhand/))
		if(SEND_SIGNAL(item, COMSIG_IS_TWOHANDED))
			return
	// If it's another offhand, or literally anything else, qdel.
	qdel(src)
