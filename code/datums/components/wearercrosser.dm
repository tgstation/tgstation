///Calls crossed on the worn item when the mob wearing it gets crossed
/datum/component/wearertargeting/wearer_crosser
	signals = list(COMSIG_MOVABLE_CROSSED)
	mobtype = /mob/living/carbon
	proctype = .proc/propogate_crossed
	var/obj/item/item

/datum/component/wearertargeting/wearer_crosser/Initialize(_valid_slots)
	. = ..()
	item = parent
	valid_slots = _valid_slots

/datum/component/wearertargeting/wearer_crosser/Destroy()
	. = ..()
	item = null

/datum/component/wearertargeting/wearer_crosser/proc/propogate_crossed(datum/source, atom/movable/AM)
	item.Crossed(AM)
