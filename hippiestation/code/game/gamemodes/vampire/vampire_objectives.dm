/datum/objective/blood/proc/gen_amount_goal(lowbound = 450, highbound = 700)
	target_amount = rand (lowbound,highbound)
	explanation_text = "Extract [target_amount] units of blood."
	return target_amount

/datum/objective/blood/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/vampire/vamp = owner.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && target_amount <= vamp.total_blood)
		return TRUE
	else
		return FALSE