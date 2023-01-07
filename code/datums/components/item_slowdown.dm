/datum/component/item_slowdown
	/// A datum with the modifiers of movement speed.
	var/datum/movespeed_modifier/modifier_datum

/datum/component/item_slowdown/Initialize(modifier_datum)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.modifier_datum = modifier_datum
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/item_slowdown/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	user.add_movespeed_modifier(modifier_datum)

/datum/component/item_slowdown/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	user.remove_movespeed_modifier(modifier_datum)
