//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	RETURN_TYPE(/list/datum/mind)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner
