/// This component is used to make a mob slower when the item the component is attached to is picked up.
/datum/component/item_slowdown
	/// A datum with the modifiers of movement speed.
	var/datum/movespeed_modifier/modifier_datum
	/// Checks if the item requires two hands.
	var/requires_twohands = FALSE

/datum/component/item_slowdown/Initialize(modifier_datum, requires_twohands = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.modifier_datum = modifier_datum
	src.requires_twohands = requires_twohands
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/// When a mob picks the item up.
/datum/component/item_slowdown/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(requires_twohands)
		if(ishuman(user))
			var/mob/living/carbon/human/human_target = user
			if(ismonkey(human_target))
				return
			if(!istype(human_target.get_inactive_held_item(), /obj/item/offhand))
				return
			if(human_target.usable_hands < 2)
				return
	user.add_movespeed_modifier(modifier_datum)

/// When a mob drops the item.
/datum/component/item_slowdown/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	user.remove_movespeed_modifier(modifier_datum)
