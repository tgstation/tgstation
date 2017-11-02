
/mob/CanContractDisease(datum/disease/D)
	if(stat == DEAD)
		return FALSE

	if(D.GetDiseaseID() in resistances)
		return FALSE

	if(HasDisease(D))
		return FALSE

	if(!(type in D.viable_mobtypes))
		return FALSE
//The next would normally be missing in the base proc but its needed to allow for and cap the number of viruses on your system.
	if(count_by_type(viruses, /datum/disease/advance) >= 3)
		return FALSE

	return TRUE
//Normally the below proc would have a set of stuff to cause a new infecting virus to kill an existing one based on its stats, this was removed.
/mob/AddDisease(datum/disease/D)
	var/datum/disease/DD = new D.type(1, D, 0)
	viruses += DD
	DD.affected_mob = src
	SSdisease.active_diseases += DD

	//Copy properties over. This is so edited diseases persist.
	var/list/skipped = list("affected_mob","holder","carrier","stage","type","parent_type","vars","transformed")
	for(var/V in DD.vars)
		if(V in skipped)
			continue
		if(istype(DD.vars[V],/list))
			var/list/L = D.vars[V]
			DD.vars[V] = L.Copy()
		else
			DD.vars[V] = D.vars[V]

	DD.affected_mob.med_hud_set_status()