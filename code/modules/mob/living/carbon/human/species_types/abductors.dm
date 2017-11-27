/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = FALSE
	species_traits = list(SPECIES_ORGANIC,NOBLOOD,NOBREATH,VIRUSIMMUNE,NOGUNS,NOHUNGER)
	mutanttongue = /obj/item/organ/tongue/abductor
	var/scientist = FALSE // vars to not pollute spieces list with castes

/datum/species/abductor/copy_properties_from(datum/species/abductor/old_species)
	scientist = old_species.scientist
