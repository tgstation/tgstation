/datum/dna	//hippie start, re-add cloning
	var/delete_species = TRUE //Set to FALSE when a body is scanned by a cloner to fix #38875

/datum/dna/Destroy()
	..()
	if(delete_species)
		QDEL_NULL(species)	//hippie start, re-add cloning
