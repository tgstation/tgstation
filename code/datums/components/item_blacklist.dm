/datum/component/item_blacklist
	can_transfer = TRUE
	/// Typecache of items you can't hold
	var/blacklist
	/// Message shown if you try to pick up an item not in the blacklist
	var/message = "You don't like %TARGET, why would you hold it?"
	/// An optional callback we check for overriding our blacklist
	var/datum/callback/tertiary_condition = null

/datum/component/item_blacklist/Initialize(blacklist, message, tertiary_condition)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.blacklist = blacklist
	if(message)
		src.message = message
	if(tertiary_condition)
		src.tertiary_condition = tertiary_condition

/datum/component/item_blacklist/Destroy(force)
	tertiary_condition = null
	return ..()

/datum/component/item_blacklist/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_TRY_PUT_IN_HAND, PROC_REF(particularly))

/datum/component/item_blacklist/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_TRY_PUT_IN_HAND)

/datum/component/item_blacklist/PostTransfer(datum/new_parent)
	if(!ismob(new_parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/item_blacklist/InheritComponent(datum/component/item_blacklist/friend, i_am_original, list/arguments)
	if(i_am_original)
		blacklist = friend.blacklist
		message = friend.message

/datum/component/item_blacklist/proc/particularly(datum/source, obj/item/pickingup)
	SIGNAL_HANDLER
	// if we were passed the output of a callback, check against that
	if(!tertiary_condition?.Invoke() && is_type_in_typecache(pickingup, blacklist))
		to_chat(source, span_warning("[replacetext(message, "%TARGET", pickingup)]"))
		return COMPONENT_LIVING_CANT_PUT_IN_HAND

