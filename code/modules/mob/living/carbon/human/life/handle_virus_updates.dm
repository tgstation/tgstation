//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return 0 //Godmode
	if(bodytemperature > 406) //Holy mother of hardcoding
		for(var/datum/disease/D in viruses)
			D.cure()
		for(var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			V.cure(src)

	src.findAirborneVirii()

	for(var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		if(isnull(V)) // Trying to figure out a runtime error that keeps repeating
			CRASH("virus2 nulled before calling activate()")
		else
			V.activate(src)
		//Activate may have deleted the virus
		if(!V)
			continue

		//Check if we're immune
		if(V.antigen & src.antibodies)
			V.dead = 1

	return
