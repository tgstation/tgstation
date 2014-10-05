/datum/round_event_control/spooky
	name = "2 SPOOKY! (Halloween)"
	holidayID = "Halloween"
	typepath = /datum/round_event/spooky
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/spooky/start()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna)
			if(prob(50))
				hardset_dna(H, null, null, null, null, /datum/species/skeleton)
			else
				hardset_dna(H, null, null, null, null, /datum/species/zombie)
	for(var/mob/living/simple_animal/corgi/Ian/Ian in mob_list)
		Ian.place_on_head(new /obj/item/weapon/bedsheet(Ian))

	spawn_meteors(5, meteorsSPOOKY)

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			new /mob/living/simple_animal/hostile/carp/eyeball(C.loc)

/datum/round_event/spooky/announce()
	priority_announce(pick("RATTLE ME BONES!","THE RIDE NEVER ENDS!", "A SKELETON POPS OUT!", "SPOOKY SCARY SKELETONS!", "CREWMEMBERS BEWARE, YOU'RE IN FOR A SCARE!") , "THE CALL IS COMING FROM INSIDE THE HOUSE")
