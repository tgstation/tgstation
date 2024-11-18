/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_CARBON_SOUNDBANG)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducebang)
	var/reduce_amount = 1

/datum/component/wearertargeting/earprotection/Initialize(valid_slots, reduce_amount = 1)
	. = ..()
	src.valid_slots = valid_slots
	if(reduce_amount)
		src.reduce_amount = reduce_amount

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	reflist[1] -= reduce_amount
