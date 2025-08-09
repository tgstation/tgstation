/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_CARBON_SOUNDBANG)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducebang)
	var/reduce_amount = 1
	valid_slots = ITEM_SLOT_EARS | ITEM_SLOT_HEAD

/datum/component/wearertargeting/earprotection/Initialize(reduce_amount = 1)
	. = ..()
	if(reduce_amount)
		src.reduce_amount = reduce_amount

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	reflist[1] -= reduce_amount
