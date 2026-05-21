/// Item is slippery - picking it up or using it may cause it to immediately fall out of the user's hands
/datum/component/slippery_item
	/// Chance the item will fall on pick up or use
	var/fall_chance = 50
	/// Chance the mob will catch the item if it falls (if they have an empty hand)
	var/fall_catch_chance = 0
	/// Message appended to examine when examining the item
	var/examine_msg
	/// Optional wash flags that removes the effect if washed
	var/wash_flags = NONE
	/// World.time of the last fall to avoid same tick falls
	VAR_PRIVATE/last_fall

/datum/component/slippery_item/Initialize(fall_chance = 50, fall_catch_chance = 0, examine_msg, duration = INFINITY, wash_flags = NONE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.fall_chance = fall_chance
	src.fall_catch_chance = fall_catch_chance
	src.examine_msg = examine_msg || "It looks very slippery, and may fall out of your hands when you try to use it."
	src.wash_flags = wash_flags
	if(duration != INFINITY)
		QDEL_IN(src, duration)

/datum/component/slippery_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))
	// bunch of generic "item used" triggers, feel free to expand
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_preattack))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(on_tryfire))
	RegisterSignal(parent, COMSIG_GRENADE_ARMED, PROC_REF(on_grenade_arm))
	RegisterSignal(parent, COMSIG_ITEM_USED_IN_SURGERY, PROC_REF(on_surgery_started))

/datum/component/slippery_item/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_PRE_ATTACK,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_GUN_TRY_FIRE,
		COMSIG_GRENADE_ARMED,
		COMSIG_ITEM_USED_IN_SURGERY,
	))

/datum/component/slippery_item/proc/on_examine(obj/item/source, mob/living/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += examine_msg

/datum/component/slippery_item/proc/on_cleaned(obj/item/source, clean_flags)
	SIGNAL_HANDLER

	if(wash_flags && (wash_flags & clean_flags))
		qdel(src)
		return COMPONENT_CLEANED

/datum/component/slippery_item/proc/on_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER

	if(slot & ITEM_SLOT_HANDS)
		try_fall(source, user)

/datum/component/slippery_item/proc/on_preattack(obj/item/source, atom/target, mob/living/user, ...)
	SIGNAL_HANDLER

	if(try_fall(source, user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/slippery_item/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, ...)
	SIGNAL_HANDLER

	try_fall(source, user)

/datum/component/slippery_item/proc/on_tryfire(obj/item/source, mob/living/user, ...)
	SIGNAL_HANDLER

	if(try_fall(source, user))
		return COMPONENT_CANCEL_GUN_FIRE

/datum/component/slippery_item/proc/on_grenade_arm(obj/item/source, ...)
	SIGNAL_HANDLER

	if(isliving(source.loc))
		try_fall(source, source.loc)

/datum/component/slippery_item/proc/on_surgery_started(obj/item/source, datum/surgery_operation/surgery, atom/movable/operating_on, mob/living/surgeon)
	SIGNAL_HANDLER

	if(try_fall(source, surgeon))
		return ITEM_INTERACT_BLOCKING

/// Check for falling and handle it if it happens.
/// Returns TRUE if the item fell, FALSE otherwise
/datum/component/slippery_item/proc/try_fall(obj/item/source, mob/living/user)
	set waitfor = FALSE
	// prevents fall -> catch -> fall -> catch. even though that'd be funny, you wouldn't even be able to see it happening.
	if(last_fall == world.time)
		return FALSE
	if(!prob(fall_chance))
		return FALSE
	if(source.loc != user || !user.dropItemToGround(source))
		return FALSE
	if(QDELETED(source))
		return FALSE // dropdel

	playsound(source, 'sound/misc/slip.ogg', 20, TRUE, SILENCED_SOUND_EXTRARANGE)
	source.SpinAnimation(4, 1)

	last_fall = world.time
	if(prob(fall_catch_chance) && !HAS_TRAIT(user, TRAIT_CLUMSY))
		for(var/empty_hand in user.get_empty_held_indexes())
			if(empty_hand == user.active_hand_index)
				continue
			if(user.putItemFromInventoryInHandIfPossible(source, empty_hand))
				to_chat(user, span_notice("[source] slips out of your hands - but you manage to catch it, just in time."))
			return TRUE

	to_chat(user, span_warning("[source] slips out of your hands!"))
	return TRUE
