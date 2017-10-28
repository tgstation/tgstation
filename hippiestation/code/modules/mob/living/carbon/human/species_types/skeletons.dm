/datum/species/skeleton/check_roundstart_eligible()
	return FALSE

/datum/species/skeleton/playable/check_roundstart_eligible()
	return TRUE

/datum/species/skeleton/playable
	name = "Spooky Scary Skeleton"
	id = "spookyskeleton"
	say_mod = "rattles"
	blacklisted = 0
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	mutant_organs = list(/obj/item/organ/tongue/bone)
	damage_overlay_type = ""
	species_traits = list(LIPS)
	limbs_id = "skeleton"
