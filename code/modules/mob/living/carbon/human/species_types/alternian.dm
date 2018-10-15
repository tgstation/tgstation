/datum/species/alternian
	// raça original
	name = "Alternian Troll"
	id = "alternian"
	say_mod = "says"
	blacklisted = 0 // para tds
	sexes = 1 // te,ps sexo
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	species_traits = list(NOBLOOD)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NOHUNGER,TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_FAKEDEATH)
	inherent_biotypes = list(MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/bone
	damage_overlay_type = ""
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW

/datum/species/alternian/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()