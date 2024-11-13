/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_CARBON_SOUNDBANG)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducebang)
	var/reduce_amount = 1

/datum/component/wearertargeting/earprotection/Initialize(_valid_slots, _reduce_amount = 1)
	. = ..()
	valid_slots = _valid_slots
	if(_reduce_amount)
		reduce_amount = _reduce_amount

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	reflist[1] -= reduce_amount
