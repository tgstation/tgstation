/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	blacklisted = 1
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NOHUNGER,EASYDISMEMBER,EASYLIMBATTACHMENT)
	mutant_organs = list(/obj/item/organ/tongue/bone)
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.
	disliked_food = null
