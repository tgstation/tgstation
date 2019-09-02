///Calls crossed on the worn item when the mob wearing it gets crossed
/datum/component/wearertargeting/wearer_crosser
	signals = list(COMSIG_MOVABLE_CROSSED)
	mobtype = /mob/living/carbon
	proctype = .proc/propogate_crossed

/datum/component/wearertargeting/wearer_crosser/Initialize(_valid_slots)
	. = ..()
	valid_slots = _valid_slots

/datum/component/wearertargeting/wearer_crosser/proc/propogate_crossed(obj/item/I, atom/movable/AM)
	I.Crossed(AM)
