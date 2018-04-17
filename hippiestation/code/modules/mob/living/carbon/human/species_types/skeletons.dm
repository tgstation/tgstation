/datum/species/skeleton
	attack_sound = 'hippiestation/sound/effects/skeletonhit.ogg'

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
	damage_overlay_type = ""
	species_traits = list(LIPS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	inherent_traits = list()
	limbs_id = "skeleton"
