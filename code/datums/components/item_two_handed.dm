/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 *
 */
/datum/component/two_handed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS 		// Only one of the component can exist on an item
	var/wielded = FALSE 							/// Are we holding the two handed item properly
	var/force_multiplier = 0						/// The multiplier applied to force when wielded, does not work with force_wielded, and force_unwielded
	var/force_wielded = 0	 						/// The force of the item when weilded
	var/force_unwielded = 0		 					/// The force of the item when unweilded
	var/wieldsound = FALSE 							/// Play sound when wielded
	var/unwieldsound = FALSE 						/// Play sound when unwielded
	var/attacksound = FALSE							/// Play sound on attack when wielded
	var/require_twohands = FALSE					/// Does it have to be held in both hands
	var/icon_prefix = FALSE							/// The icon prefix that will be used with the wielded status
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
 * * attacksound (optional) The sound to play when wielded and attacking
 * * force_multiplier (optional) The force multiplier when wielded, do not use with force_wielded, and force_unwielded
 * * force_wielded (optional) The force setting when the item is wielded, do not use with force_multiplier
 * * force_unwielded (optional) The force setting when the item is unwielded, do not use with force_multiplier
 * * icon_prefix (optional) The prefix of the items icon to be used with wielded status
 * * icon_update_callback (optional) proc (wielded) Callback with wielded status
 * * on_wield_callback (optional) proc (user) Callback on wield of the item
 * * on_unwield_callback (optional) proc (user) Callback on unwield of the item
 */
/datum/component/two_handed/Initialize(require_twohands=FALSE, wieldsound=FALSE, unwieldsound=FALSE, attacksound=FALSE, \
										force_multiplier=0, force_wielded=0, force_unwielded=0, icon_prefix=FALSE, \
										datum/callback/icon_update_callback=null, datum/callback/on_wield_callback=null, datum/callback/on_unwield_callback=null)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.attacksound = attacksound
	src.force_multiplier = force_multiplier
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded
	src.icon_prefix = icon_prefix
	src.icon_update_callback = icon_update_callback
	src.on_wield_callback = on_wield_callback
	src.on_unwield_callback = on_unwield_callback

// Inherit the new values passed to the component
/datum/component/two_handed/InheritComponent(datum/component/two_handed/new_comp, original, require_twohands, \
												wieldsound, unwieldsound, force_wielded, force_unwielded, icon_prefix, \
												datum/callback/icon_update_callback, datum/callback/on_wield_callback, datum/callback/on_unwield_callback)
	if(!original)
		return
	if(require_twohands)
		src.require_twohands = require_twohands
	if(wieldsound)
		src.wieldsound = wieldsound
	if(unwieldsound)
		src.unwieldsound = unwieldsound
	if(attacksound)
		src.attacksound = attacksound
	if(force_multiplier)
		src.force_multiplier = force_multiplier
	if(force_wielded)
		src.force_wielded = force_wielded
	if(force_unwielded)
		src.force_unwielded = force_unwielded
	if(icon_prefix)
		src.icon_prefix = icon_prefix
	if(icon_update_callback)
		src.icon_update_callback = icon_update_callback
	if(on_wield_callback)
		src.on_wield_callback = on_wield_callback
	if(on_unwield_callback)
		src.on_unwield_callback = on_unwield_callback

// register signals withthe parent item
/datum/component/two_handed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/on_attack_self)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, .proc/on_update_icon)
	RegisterSignal(parent, COMSIG_TRY_TWOHANDED_WIELD, .proc/try_wield)
	RegisterSignal(parent, COMSIG_TRY_TWOHANDED_UNWIELD, .proc/try_unwield)

// Remove all siginals registered to the parent item
/datum/component/two_handed/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED,
								COMSIG_ITEM_DROPPED,
								COMSIG_ITEM_ATTACK_SELF,
								COMSIG_ATOM_UPDATE_ICON,
								COMSIG_TRY_TWOHANDED_WIELD,
								COMSIG_TRY_TWOHANDED_UNWIELD))

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

	// wield update status
	wielded = TRUE
	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, .proc/on_swap_hands)
	SEND_SIGNAL(parent, COMSIG_TWOHANDED_WIELD, user)
	if(on_wield_callback)
		on_wield_callback.Invoke(user)

	// update item stats and name
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force *= force_multiplier
	else if(force_wielded)
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

	// wield update status
	wielded = FALSE
	UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	SEND_SIGNAL(parent, COMSIG_TWOHANDED_UNWIELD, user)
	if(on_unwield_callback)
		on_unwield_callback.Invoke(user)

	// update item stats
	var/obj/item/parent_item = parent
	if(force_multiplier)
		parent_item.force /= force_multiplier
	else if(force_unwielded)
		parent_item.force = force_unwielded

	// update the items name to remove the wielded status
	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else
		parent_item.name = "[initial(parent_item.name)]"

	// Update icons
	parent_item.update_icon()
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
 * on_attack triggers on attack with the parent item
 */
/datum/component/two_handed/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	if(wielded && attacksound)
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, attacksound, 50, TRUE)

/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Checked in the order listed, first found is used
 * Invokes the Icon Update Callback with wield status
 * Updates the icon using icon_prefix if set
 */
/datum/component/two_handed/proc/on_update_icon(datum/source)
	if(icon_update_callback)
		icon_update_callback.Invoke(wielded)
	else if(icon_prefix)
		var/obj/item/parent_item = parent
		if(parent_item)
			parent_item.icon_state = "[icon_prefix][wielded]"

/**
 * try_wield tries to wield the item
 */
/datum/component/two_handed/proc/try_wield(datum/source, mob/user)
	wield(user)

/**
 * try_unwield attempts to unwield the item
 */
/datum/component/two_handed/proc/try_unwield(datum/source, mob/user, show_message=TRUE)
	unwield(user, show_message)

/**
 * on_swap_hands Triggers on swapping hands, blocks swap if the other hand is busy
 */
/datum/component/two_handed/proc/on_swap_hands(mob/user, obj/item/held_item)
	if(!held_item)
		return
	var/datum/component/two_handed/comp_twohand = held_item.GetComponent(/datum/component/two_handed)
	if(comp_twohand && comp_twohand.wielded)
		return COMPONENT_BLOCK_SWAP

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
	if(item)
		var/datum/component/two_handed/comp_twohand = item.GetComponent(/datum/component/two_handed)
		if(comp_twohand)
			SEND_SIGNAL(item, COMSIG_TRY_TWOHANDED_UNWIELD, user, show_message)
			// Drop item if off hand is dropped and the item requies both hands
			if(comp_twohand.require_twohands)
				user.dropItemToGround(item)

	// delete on drop
	if(!QDELETED(src))
		qdel(src)

/obj/item/offhand/equipped(mob/user, slot)
	..()
	if(wielded && !user.is_holding(src))
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
		var/datum/component/two_handed/comp_twohand = item.GetComponent(/datum/component/two_handed)
		if(comp_twohand)
			return
	// If it's another offhand, or literally anything else, qdel.
	qdel(src)
