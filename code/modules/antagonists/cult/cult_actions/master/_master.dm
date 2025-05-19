/datum/action/innate/cult/master/IsAvailable(feedback = FALSE)
	if(!owner.mind || GLOB.cult_narsie)
		return FALSE
	var/datum/antagonist/cult/cult_datum = owner.mind.has_antag_datum(/datum/antagonist/cult)
	if(!cult_datum.is_cult_leader())
		return FALSE
	return ..()
