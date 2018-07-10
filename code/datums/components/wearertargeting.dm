// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

/datum/component/wearertargeting
	var/list/valid_slots = list()
	var/list/signals = list()
	var/datum/callback/callback = CALLBACK(GLOBAL_PROC, .proc/pass)
	var/mobtype = /mob/living

/datum/component/wearertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/wearertargeting/proc/on_equip(mob/equipper, slot)
	if((slot in valid_slots) && istype(equipper, mobtype))
		RegisterSignal(equipper, signals, callback, TRUE)
	else
		UnregisterSignal(equipper, signals)

/datum/component/wearertargeting/proc/on_drop(mob/user)
	UnregisterSignal(user, signals)

/datum/component/wearertargeting/Destroy()
	QDEL_NULL(callback) //is likely to ourselves.
	return ..()