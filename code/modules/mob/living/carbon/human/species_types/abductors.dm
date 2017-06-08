/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = 0
	species_traits = list(NOBLOOD,NOBREATH,VIRUSIMMUNE,NOGUNS,NOHUNGER)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 20, "bomb" = 0, "bio" = 50, "rad" = 50, "fire" = 0, "acid" = 0) //bizarre alien biology
	mutanttongue = /obj/item/organ/tongue/abductor
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/team = 1
