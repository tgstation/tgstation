/datum/brain_trauma
	var/clonable = TRUE // will this transfer if the brain is cloned?

/datum/brain_trauma/proc/on_clone()
	if(clonable)
		return new type
