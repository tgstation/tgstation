/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = 0
	species_traits = list(NOBLOOD,NOBREATH,VIRUSIMMUNE,NOGUNS,NOHUNGER)
	mutanttongue = /obj/item/organ/tongue/abductor
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/team = 1

/datum/species/abductor/copy_properties_from(datum/species/abductor/old_species)
	scientist = old_species.scientist
	team = old_species.team
