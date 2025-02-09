/datum/objective/survive/bloodsucker
	name = "bloodsuckersurvive"
	explanation_text = "Продержитесь всю смену, не потерпев окончательной смерти."

/datum/objective/bloodsucker_lair
	name = "claim lair"
	explanation_text = "Займите свой гроб, охраняя логово до конца смены."
	martyr_compatible = TRUE

// WIN CONDITIONS?
/datum/objective/bloodsucker_lair/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.claimed_coffin && bloodsuckerdatum.bloodsucker_lair_area)
		return TRUE
	return FALSE
