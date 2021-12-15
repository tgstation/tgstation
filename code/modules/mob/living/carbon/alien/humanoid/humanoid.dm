/mob/living/carbon/human/species/alien/get_permeability_protection(list/target_zones)
	return 0.8

/mob/living/carbon/human/species/alien/alien_evolve(mob/living/carbon/human/species/alien/humanoid/new_xeno)
	drop_all_held_items()
	..()
