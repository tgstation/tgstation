/datum/round_event_control/spooky
	name = "2 SPOOKY!"
	holidayID = "Halloween"
	typepath = /datum/round_event/spooky
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/spooky/start()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna)
			hardset_dna(H, null, null, null, "skeleton")
	for(var/mob/living/simple_animal/corgi/Ian/Ian in mob_list)
		Ian.place_on_head(new /obj/item/weapon/bedsheet(Ian))

/datum/round_event/spooky/announce()
	command_alert(pick("RATTLE ME BONES!","THE RIDE NEVER ENDS!", "A SKELETON POPS OUT!", "SPOOKY SCARY SKELETONS!", "CREWMEMBERS BEWARE, YOU'RE IN FOR A SCARE!") , "THE CALL IS COMING FROM INSIDE THE HOUSE")