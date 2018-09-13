/datum/AI_Module/proc/can_be_bought(mob/living/silicon/ai/AI)
	return TRUE

/datum/AI_Module/large/nuke_station/can_be_bought(mob/living/silicon/ai/AI)
	return ..() && (AI.mind && !AI.mind.has_antag_datum(ANTAG_DATUM_HIJACKEDAI))