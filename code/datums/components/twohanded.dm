/**
 * Two Handed Component
 *
 * When applied to an item it will make it two handed
 * Only one of the component can exist on an item.
 */
/datum/component/two_handed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Are we holding the two handed item properly
	var/wielded = FALSE
	/// The multiplier applied to force when wielded, does not work with force_wielded, and force_unwielded
	var/force_multiplier = 1
	/// The force of the item when weilded
	var/force_wielded = 0
	/// The force of the item when unweilded
	var/force_unwielded = 0
	/// Boolean whether to play sound when wielded
	var/wieldsound = FALSE
	/// Boolean whether to play sound when unwielded
	var/unwieldsound = FALSE
	/// Boolean whether to play sound on attack, if wielded
	var/attacksound = FALSE
	/// Boolean on whether it has to be held in both hands
	var/require_twohands = FALSE
	/// The icon that will be used when wielded
	var/icon_wielded = FALSE
	/// Reference to the offhand created for the item
	var/obj/item/offhand/offhand_item = null
	/// The amount of increase recived from sharpening the item
	var/sharpened_increase = 0
	/// A callback on the parent to be called when the item is wielded
	var/datum/callback/wield_callback
	/// A callback on the parent to be called when the item is unwielded
	var/datum/callback/unwield_callback

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
 * * icon_wielded (optional) The icon to be used when wielded
 */
/datum/component/two_handed/Initialize(
	require_twohands = FALSE,
	wieldsound = FALSE,
	unwieldsound = FALSE,
	attacksound = FALSE,
	force_multiplier = 1,
	force_wielded = 0,
	force_unwielded = 0,
	icon_wielded = FALSE,
	datum/callback/wield_callback,
	datum/callback/unwield_callback,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.require_twohands = require_twohands
	src.wieldsound = wieldsound
	src.unwieldsound = unwieldsound
	src.attacksound = attacksound
	src.force_multiplier = force_multiplier
	src.force_wielded = force_wielded
	src.force_unwielded = force_unwielded
	src.icon_wielded = icon_wielded
	src.wield_callback = wield_callback
	src.unwield_callback = unwield_callback

	if(require_twohands)
		ADD_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS, ABSTRACT_ITEM_TRAIT)

/datum/component/two_handed/Destroy(force)
	offhand_item = null
	wield_callback = null
	unwield_callback = null
	return ..()

// Inherit the new values passed to the component
/datum/component/two_handed/InheritComponent(
	datum/component/two_handed/new_comp,
	original,
	require_twohands,
	wieldsound,
	unwieldsound,
	attacksound,
	force_multiplier,
	force_wielded,
	force_unwielded,
	icon_wielded,
	datum/callback/wield_callback,
	datum/callback/unwield_callback,
)
	if(!original)
		return
	var/obj/item/parent_item = parent
	if(wielded)
		if(sharpened_increase)
			parent_item.force -= sharpened_increase
		if(force_multiplier)
			parent_item.force /= force_multiplier
		else if(!isnull(force_unwielded))
			parent_item.force = force_unwielded
	if(!isnull(require_twohands))
		src.require_twohands = require_twohands
	if(wieldsound)
		src.wieldsound = wieldsound
	if(unwieldsound)
		src.unwieldsound = unwieldsound
	if(attacksound)
		src.attacksound = attacksound
	if(force_multiplier)
		src.force_multiplier = force_multiplier
	if(!isnull(force_wielded))
		src.force_wielded = force_wielded
	if(isnull(force_unwielded))
		src.force_unwielded = force_unwielded
	if(icon_wielded)
		src.icon_wielded = icon_wielded
	if(wield_callback)
		src.wield_callback = wield_callback
	if(unwield_callback)
		src.unwield_callback = unwield_callback
	if(!wielded)
		return
	if(!isnull(force_multiplier))
		parent_item.force *= force_multiplier
	else if(!isnull(force_wielded))
		parent_item.force = force_wielded
	if(!isnull(sharpened_increase))
		parent_item.force += sharpened_increase

// register signals withthe parent item
/datum/component/two_handed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_icon))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))
	RegisterSignal(parent, COMSIG_ITEM_APPLY_FANTASY_BONUSES, PROC_REF(apply_fantasy_bonuses))
	RegisterSignal(parent, COMSIG_ITEM_REMOVE_FANTASY_BONUSES, PROC_REF(remove_fantasy_bonuses))

// Remove all siginals registered to the parent item
/datum/component/two_handed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_POST_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK,
		COMSIG_ATOM_UPDATE_ICON,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_SHARPEN_ACT,
		COMSIG_ITEM_APPLY_FANTASY_BONUSES,
		COMSIG_ITEM_REMOVE_FANTASY_BONUSES,
	))

/// Triggered on equip of the item containing the component
/datum/component/two_handed/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS) && (slot & ITEM_SLOT_HANDS)) // force equip the item
		wield(user)
	if(!user.is_holding(parent) && wielded && !HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
		unwield(user)

/// Triggered on drop of item containing the component
/datum/component/two_handed/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS)) //Don't let the item fall to the ground and cause bugs if it's actually being equipped on another slot.
		unwield(user, FALSE, FALSE)
	if(wielded)
		unwield(user)
	if(source == offhand_item && !QDELETED(source))
		offhand_item = null
		qdel(source)

/// Triggered on destroy of the component's offhand
/datum/component/two_handed/proc/on_destroy(datum/source)
	SIGNAL_HANDLER
	offhand_item = null

/// Triggered on attack self of the item containing the component
/datum/component/two_handed/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
		if(wielded)
			unwield(user)
		else if(user.is_holding(parent))
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

	var/atom/atom_parent = parent
	if(HAS_TRAIT(user, TRAIT_NO_TWOHANDING))
		if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
			atom_parent.balloon_alert(user, "can't wield!")
			user.dropItemToGround(parent, force = TRUE)
		else
			atom_parent.balloon_alert(user, "can't wield with both hands!")
		return COMPONENT_EQUIPPED_FAILED
	if(user.get_inactive_held_item())
		if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
			atom_parent.balloon_alert(user, "can't carry in one hand!")
			user.dropItemToGround(parent, force = TRUE)
		else
			atom_parent.balloon_alert(user, "holding something in other hand!")
		return COMPONENT_EQUIPPED_FAILED
	if(user.usable_hands < 2)
		if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
			user.dropItemToGround(parent, force = TRUE)
		atom_parent.balloon_alert(user, "not enough hands!")
		return COMPONENT_EQUIPPED_FAILED

	// wield update status
	if(SEND_SIGNAL(parent, COMSIG_TWOHANDED_WIELD, user) & COMPONENT_TWOHANDED_BLOCK_WIELD)
		user.dropItemToGround(parent, force = TRUE)
		return COMPONENT_EQUIPPED_FAILED // blocked wield from item
	if (wield_callback?.Invoke(parent, user) & COMPONENT_TWOHANDED_BLOCK_WIELD)
		return
	wielded = TRUE
	ADD_TRAIT(parent, TRAIT_WIELDED, REF(src))
	RegisterSignal(user, COMSIG_MOB_SWAPPING_HANDS, PROC_REF(on_swapping_hands))

	// update item stats and name
	var/obj/item/parent_item = parent
	if(force_multiplier != 1)
		parent_item.force *= force_multiplier
	else if(force_wielded != force_unwielded)
		parent_item.force = force_wielded
	if(sharpened_increase)
		parent_item.force += sharpened_increase
	parent_item.name = "[parent_item.name] (Wielded)"
	parent_item.update_appearance()

	if(iscyborg(user))
		to_chat(user, span_notice("You dedicate your module to [parent]."))
	else
		to_chat(user, span_notice("You grab [parent] with both hands."))

	// Play sound if one is set
	if(wieldsound)
		playsound(parent_item.loc, wieldsound, 50, TRUE)

	// Let's reserve the other hand
	offhand_item = new(user)
	offhand_item.name = "[parent_item.name] - offhand"
	offhand_item.desc = "Your second grip on [parent_item]."
	offhand_item.wielded = TRUE
	RegisterSignal(offhand_item, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(offhand_item, COMSIG_QDELETING, PROC_REF(on_destroy))
	user.put_in_inactive_hand(offhand_item)

/**
 * Unwield the two handed item
 *
 * vars:
 * * user The mob/living/carbon that is unwielding the item
 * * show_message (option) show a message to chat on unwield
 * * can_drop (option) whether 'dropItemToGround' can be called or not.
 */
/datum/component/two_handed/proc/unwield(mob/living/carbon/user, show_message=TRUE, can_drop=TRUE)
	if(!wielded)
		return

	// wield update status
	wielded = FALSE
	UnregisterSignal(user, COMSIG_MOB_SWAPPING_HANDS)
	SEND_SIGNAL(parent, COMSIG_TWOHANDED_UNWIELD, user)
	REMOVE_TRAIT(parent, TRAIT_WIELDED, REF(src))
	unwield_callback?.Invoke(parent, user)

	// update item stats
	var/obj/item/parent_item = parent
	if(sharpened_increase)
		parent_item.force -= sharpened_increase
	if(force_multiplier != 1)
		parent_item.force /= force_multiplier
	else if(force_unwielded != force_wielded)
		parent_item.force = force_unwielded

	// update the items name to remove the wielded status
	var/sf = findtext(parent_item.name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		parent_item.name = copytext(parent_item.name, 1, sf)
	else
		parent_item.name = "[initial(parent_item.name)]"

	// Update icons
	parent_item.update_appearance()

	if(istype(user)) // tk showed that we might not have a mob here
		if(user.get_item_by_slot(ITEM_SLOT_BACK) == parent)
			user.update_worn_back()
		else
			user.update_held_items()

		// if the item requires two handed drop the item on unwield
		if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS) && can_drop)
			user.dropItemToGround(parent, force=TRUE)

		// Show message if requested
		if(show_message)
			if(iscyborg(user))
				to_chat(user, span_notice("You free up your module."))
			else if(HAS_TRAIT(parent, TRAIT_NEEDS_TWO_HANDS))
				to_chat(user, span_notice("You drop [parent]."))
			else
				to_chat(user, span_notice("You are now carrying [parent] with one hand."))

	// Play sound if set
	if(unwieldsound)
		playsound(parent_item.loc, unwieldsound, 50, TRUE)

	// Remove the object in the offhand
	if(offhand_item)
		UnregisterSignal(offhand_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
		qdel(offhand_item)
	// Clear any old refrence to an item that should be gone now
	offhand_item = null

/**
 * on_attack triggers on attack with the parent item
 */
/datum/component/two_handed/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(wielded && attacksound)
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, attacksound, 50, TRUE)

/**
 * on_update_icon triggers on call to update parent items icon
 *
 * Updates the icon using icon_wielded if set
 */
/datum/component/two_handed/proc/on_update_icon(obj/item/source)
	SIGNAL_HANDLER
	if(!wielded)
		return NONE
	if(!icon_wielded)
		return NONE
	source.icon_state = icon_wielded
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/**
 * on_moved Triggers on item moved
 */
/datum/component/two_handed/proc/on_moved(datum/source, mob/user, dir)
	SIGNAL_HANDLER

	unwield(user, can_drop=FALSE)

/**
 * on_swap_hands Triggers on swapping hands, blocks swap if the other hand is busy
 */
/datum/component/two_handed/proc/on_swapping_hands(mob/user, obj/item/held_item)
	SIGNAL_HANDLER

	if(!held_item)
		return
	if(held_item == parent)
		return COMPONENT_BLOCK_SWAP

/**
 * on_sharpen Triggers on usage of a sharpening stone on the item
 */
/datum/component/two_handed/proc/on_sharpen(obj/item/item, amount, max_amount)
	SIGNAL_HANDLER

	if(!item)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	if(sharpened_increase)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	var/wielded_val = 0
	if(force_multiplier)
		var/obj/item/parent_item = parent
		if(wielded)
			wielded_val = parent_item.force
		else
			wielded_val = parent_item.force * force_multiplier
	else
		wielded_val = force_wielded
	if(wielded_val > max_amount)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_increase = min(amount, (max_amount - wielded_val))
	return COMPONENT_BLOCK_SHARPEN_APPLIED

/datum/component/two_handed/proc/apply_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	force_wielded = source.modify_fantasy_variable("force_wielded", force_wielded, bonus)
	force_unwielded = source.modify_fantasy_variable("force_unwielded", force_unwielded, bonus)
	if(wielded && ismob(source.loc))
		unwield(source.loc)
	if(force_multiplier)
		force_multiplier = source.modify_fantasy_variable("force_multiplier", force_multiplier, bonus/10, minimum = 1)

/datum/component/two_handed/proc/remove_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	force_wielded = source.reset_fantasy_variable("force_wielded", force_wielded)
	force_unwielded = source.reset_fantasy_variable("force_unwielded", force_unwielded)
	if(wielded && ismob(source.loc))
		unwield(source.loc)
	force_multiplier = source.reset_fantasy_variable("force_multiplier", force_multiplier)

/**
 * The offhand dummy item for two handed items
 */
/obj/item/offhand
	name = "offhand"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/wielded = FALSE // Off Hand tracking of wielded status

/obj/item/offhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/offhand/Destroy()
	wielded = FALSE
	return ..()

/obj/item/offhand/equipped(mob/user, slot)
	. = ..()
	if(wielded && !user.is_holding(src) && !QDELETED(src))
		qdel(src)
