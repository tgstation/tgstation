/datum/generecipe
	var/required = list()
	var/result = null

/datum/generecipe/New()
	. = ..()
	GLOB.mutation_recipes[required] = result
	qdel(src) //We dont need this anymore, might aswell throw it away

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	for(var/list/A in GLOB.mutation_recipes)
		if(A.Find(mutation1) && A.Find(mutation2))
			return GLOB.mutation_recipes[A]

/datum/generecipe/hulk
	required = list(STRONG, RADIOACTIVE)
	result = HULK