/datum/objective/survive/bloodsucker
	name = "bloodsuckersurvive"
	explanation_text = "Survive the entire shift without succumbing to Final Death."

/datum/objective/bloodsucker_lair
	name = "claim lair"
	explanation_text = "Create a lair by claiming a coffin, and protect it until the end of the shift."
	martyr_compatible = TRUE

// WIN CONDITIONS?
/datum/objective/bloodsucker_lair/check_completion()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.claimed_coffin && bloodsuckerdatum.bloodsucker_lair_area)
		return TRUE
	return FALSE
