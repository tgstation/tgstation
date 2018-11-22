/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/A in GLOB.mutation_recipes)
		if(("[mutation1]" in A) && ("[mutation2]" in A))
			return GLOB.mutation_recipes[A]

/datum/generecipe/hulk
	required = "/datum/mutation/human/strong; /datum/mutation/human/radioactive"
	result = HULK