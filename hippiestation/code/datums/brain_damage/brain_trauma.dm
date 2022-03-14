/datum/brain_trauma	//hippie start, re-add cloning
	var/clonable = TRUE // will this transfer if the brain is cloned?

/datum/brain_trauma/proc/on_clone()	//hippie end, re-add cloning
	if(clonable)
		return new type
