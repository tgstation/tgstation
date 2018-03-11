
/mob/living/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return FALSE

	if(D.GetDiseaseID() in disease_resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(!(type in D.viable_mobtypes))
		return FALSE
//The next would normally be missing in the base proc but its needed to allow for and cap the number of viruses on your system.
	if(count_by_type(diseases, /datum/disease/advance) >= 3)
		return FALSE

	return TRUE
