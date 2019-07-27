// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

/datum/component/wearertargeting
	var/list/valid_slots = list()
	var/list/signals = list()
<<<<<<< HEAD
	var/proctype = .proc/pass
=======
	var/datum/callback/callback = CALLBACK(GLOBAL_PROC, .proc/pass)
>>>>>>> Updated this old code to fork
	var/mobtype = /mob/living

/datum/component/wearertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/component/wearertargeting/proc/on_equip(datum/source, mob/equipper, slot)
	if((slot in valid_slots) && istype(equipper, mobtype))
<<<<<<< HEAD
		RegisterSignal(equipper, signals, proctype, TRUE)
=======
		RegisterSignal(equipper, signals, callback, TRUE)
>>>>>>> Updated this old code to fork
	else
		UnregisterSignal(equipper, signals)

/datum/component/wearertargeting/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, signals)
<<<<<<< HEAD
=======

/datum/component/wearertargeting/Destroy()
	QDEL_NULL(callback) //is likely to ourselves.
	return ..()
>>>>>>> Updated this old code to fork
