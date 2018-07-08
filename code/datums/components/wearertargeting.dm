// A dummy parent type used for easily making components that target an item's wearer rather than the item itself.

/datum/component/wearertargeting
	var/datum/component/mobhook
	var/list/valid_slots = list()
	var/list/signals = list()
	var/datum/callback/callback = CALLBACK(GLOBAL_PROC, .proc/pass)
	var/mobtype = /mob/living

/datum/component/wearertargeting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/checkMobHook)

/datum/component/wearertargeting/Destroy()
	QDEL_NULL(mobhook)
	return ..()

/datum/component/wearertargeting/proc/checkMobHook(mob/user, slot)
	if ((slot in valid_slots) && istype(user, mobtype))
		if (mobhook && mobhook.parent != user)
			QDEL_NULL(mobhook)
		if (!mobhook)
			mobhook = user.AddComponent(/datum/component/redirect, signals, callback)
	else
		QDEL_NULL(mobhook)
