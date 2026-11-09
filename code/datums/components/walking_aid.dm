/**
 * Walking Aid Component
 *
 * Add this to an item to allow it to act as a cane (or crutch) while held.
 * Items with this component will help mobs avoid limping from broken
 * leg bones, and lessen the slowdown caused by missing legs.
 *
 * Used by canes, crutches, and pole-like items such as spears and staffs.
 */
/datum/component/walking_aid
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Causes a mob to waddle (wiggle) while walking when holding this object
	var/waddling = FALSE
	/// If set, the parent item must have this trait for the support to function
	var/required_trait
	/// Weakref to the mob currently being supported
	var/datum/weakref/current_user_ref
	/// The amount of slowdown to reduce for a limbless leg
	var/limbless_slowdown_modifier = 0.6 // reduces slowdown by 40%

/datum/component/walking_aid/Initialize(limbless_slowdown_modifier = 0.6, required_trait = null, waddling = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.waddling = waddling
	src.required_trait = required_trait
	src.limbless_slowdown_modifier = limbless_slowdown_modifier

/datum/component/walking_aid/Destroy(force)
	remove_support()
	return ..()

/datum/component/walking_aid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_WIELDED), PROC_REF(update_legs))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_WIELDED), PROC_REF(update_legs))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(required_trait), PROC_REF(update_legs))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(required_trait), PROC_REF(update_legs))

/datum/component/walking_aid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_EXAMINE_TAGS,
		SIGNAL_ADDTRAIT(TRAIT_WIELDED),
		SIGNAL_REMOVETRAIT(TRAIT_WIELDED),
		SIGNAL_ADDTRAIT(required_trait),
		SIGNAL_REMOVETRAIT(required_trait),
	))
	remove_support()

/datum/component/walking_aid/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	remove_support()
	if(!(slot & ITEM_SLOT_HANDS))
		return
	if(!isliving(equipper))
		return

	apply_support(equipper)

/datum/component/walking_aid/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	remove_support()

/datum/component/walking_aid/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list["walking-aid"] = "It can help lessen the slowdown caused from a missing or injured leg, when held on the same side as the injury."

// Updates our leg status when wielded/unwielded a two handed walking aid like a spear
/datum/component/walking_aid/proc/update_legs(atom/source)
	SIGNAL_HANDLER

	var/mob/living/user = current_user_ref?.resolve()
	user?.update_usable_leg_status()

/datum/component/walking_aid/proc/apply_support(mob/living/user)
	if(current_user_ref)
		remove_support()

	current_user_ref = WEAKREF(user)
	RegisterSignal(user, COMSIG_CARBON_LIMPING, PROC_REF(handle_limping))
	RegisterSignal(user, COMSIG_LIVING_LIMBLESS_SLOWDOWN, PROC_REF(handle_slowdown))
	user.update_usable_leg_status()

	if(waddling)
		user.AddElementTrait(TRAIT_WADDLING, REF(src), /datum/element/waddling)

/datum/component/walking_aid/proc/remove_support()
	var/mob/living/user = current_user_ref?.resolve()
	current_user_ref = null
	if(isnull(user))
		return
	UnregisterSignal(user, list(COMSIG_CARBON_LIMPING, COMSIG_LIVING_LIMBLESS_SLOWDOWN))
	user.update_usable_leg_status()

	if(waddling)
		REMOVE_TRAIT(user, TRAIT_WADDLING, REF(src))

/datum/component/walking_aid/proc/is_active()
	// if both hands are holding it, then it is not being used for support
	if(HAS_TRAIT(parent, TRAIT_WIELDED))
		return FALSE

	if(isnull(required_trait))
		return TRUE

	return HAS_TRAIT(parent, required_trait)

/datum/component/walking_aid/proc/handle_limping(mob/living/user, obj/item/bodypart/limping_leg)
	SIGNAL_HANDLER

	if(!is_active())
		return NONE
	if(isnull(limping_leg))
		return NONE

	var/supported_zone = get_supported_leg_zone(user)
	if(isnull(supported_zone))
		return NONE
	if(limping_leg.body_zone != supported_zone)
		return NONE

	return COMPONENT_CANCEL_LIMP

/datum/component/walking_aid/proc/handle_slowdown(mob/living/user, limbless_slowdown, list/slowdown_mods)
	SIGNAL_HANDLER

	if(!is_active())
		return
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	var/leg_amount = carbon_user.usable_legs
	if(leg_amount >= carbon_user.default_num_legs)
		return
	if(!leg_amount) // someday support dual-wielding crutches but for now they are destined to waddle
		return

	var/supported_zone = get_supported_leg_zone(user)
	if(isnull(supported_zone))
		return
	if(carbon_user.get_bodypart(supported_zone)) // make sure their leg is actually missing
		return

	slowdown_mods += limbless_slowdown_modifier

/datum/component/walking_aid/proc/get_supported_leg_zone(mob/living/user)
	var/held_hand_zone = user.get_hand_zone_of_item(parent)

	switch(held_hand_zone)
		if(BODY_ZONE_R_ARM)
			return BODY_ZONE_R_LEG
		if(BODY_ZONE_L_ARM)
			return BODY_ZONE_L_LEG
		else
			return null
