/datum/round_event_control/wizard/race //Lizard Wizard? Lizard Wizard.
	name = "Race Swap"
	weight = 2
	typepath = /datum/round_event/wizard/race/
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/race/start()

	var/all_the_same = 0
	var/all_species = list()

	for(var/speciestype in typesof(/datum/species) - /datum/species)
		var/datum/species/S = new speciestype()
		if(!S.dangerous_existence)
			all_species += speciestype

	var/new_species = pick(all_species)

	if(prob(50))
		all_the_same = 1

	for(var/mob/living/carbon/human/H in mob_list) //yes, even the dead
		if(H.dna)
			hardset_dna(H, null, null, null, null, new_species)
			H.regenerate_icons()
			H << "<span class='notice'>You feel somehow... different?</span>"
		if(!all_the_same)
			new_species = pick(all_species)
