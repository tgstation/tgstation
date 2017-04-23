/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = 0
	species_traits = list(NOBLOOD,NOBREATH,VIRUSIMMUNE,NOGUNS,NOHUNGER)
	mutant_organs = list(/obj/item/organ/tongue/abductor)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/team = 1