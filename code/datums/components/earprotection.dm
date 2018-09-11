/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_CARBON_SOUNDBANG)
	mobtype = /mob/living/carbon

/datum/component/wearertargeting/earprotection/Initialize(_valid_slots)
	. = ..()
	valid_slots = _valid_slots
	callback = CALLBACK(src, .proc/reducebang)

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	reflist[1]--
