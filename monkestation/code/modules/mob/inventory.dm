/mob/living/carbon/human/proc/get_pockets()
	var/list/pockets = list()
	if(l_store)
		pockets += l_store
	if(r_store)
		pockets += r_store
	if(s_store)
		pockets += s_store
	return pockets
