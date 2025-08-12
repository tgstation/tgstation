// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

/datum/component/wearertargeting
	/// Bitflag value of valid slots.
	/// You can find all slot bitflags in code/__DEFINES/inventory.dm
	var/valid_slots = NONE
	var/list/signals = list()
	var/proctype = GLOBAL_PROC_REF(pass)
	var/mobtype = /mob/living

/datum/component/wearertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/wearertargeting/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if((valid_slots & slot) && istype(equipper, mobtype))
		RegisterSignals(equipper, signals, proctype, TRUE)
	else
		UnregisterSignal(equipper, signals)

/datum/component/wearertargeting/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, signals)
