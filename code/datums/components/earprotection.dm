/datum/component/wearertargeting/earprotection
	signals = list(COMSIG_CARBON_SOUNDBANG)
	mobtype = /mob/living/carbon
<<<<<<< HEAD
	proctype = .proc/reducebang
=======
>>>>>>> Updated this old code to fork

/datum/component/wearertargeting/earprotection/Initialize(_valid_slots)
	. = ..()
	valid_slots = _valid_slots
<<<<<<< HEAD
=======
	callback = CALLBACK(src, .proc/reducebang)
>>>>>>> Updated this old code to fork

/datum/component/wearertargeting/earprotection/proc/reducebang(datum/source, list/reflist)
	reflist[1]--
