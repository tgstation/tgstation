/datum/mind
		var/datum/ambitions/my_ambitions

/datum/mind/proc/ambition_submit()
	for(var/datum/antagonist/A in antag_datums)
		if(A.uses_ambitions)
			A.ambitions_add()
