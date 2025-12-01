///Whenever get_ear_protection() is called, this proc adds 'protection_value' to the wearer's natural ear protection.
/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_LIVING_GET_EAR_PROTECTION)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducebang)
	//positive amount indicating how much protection this gives
	var/protection_amount = 1
	valid_slots = ITEM_SLOT_EARS | ITEM_SLOT_HEAD

/datum/component/wearertargeting/earprotection/Initialize(protection_amount = EAR_PROTECTION_NORMAL)
	. = ..()
	src.protection_amount = protection_amount

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	SIGNAL_HANDLER
	reflist[EAR_PROTECTION_ARG] += protection_amount
