/*				SECURITY OBJECTIVES				*/

/datum/objective/crew/enjoyyourstay
	explanation_text = "Enforce Space Law to the best of your ability."
	jobs = "headofsecurity,securityofficer,warden,detective"

/datum/objective/crew/enjoyyourstay/check_completion()
	if(owner && owner.current)
		if(owner.current.stat != DEAD)
			return TRUE
	return FALSE

/datum/objective/crew/justicecrew
	explanation_text = "Ensure there are no innocent crew members in the brig when the shift ends."
	jobs = "lawyer"

/datum/objective/crew/justicecrew/check_completion()
	if(owner && owner.current)
		for(var/datum/mind/M in SSticker.minds)
			if(M.current && isliving(M.current))
				if(!M.special_role && !(M.assigned_role == "Security Officer") && !(M.assigned_role == "Detective") && !(M.assigned_role == "Head of Security") && !(M.assigned_role == "Lawyer") && !(M.assigned_role == "Warden") && get_area(M.current) != typesof(/area/security))
					return FALSE
		return TRUE
