/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	sexes = 0
	blacklisted = 1
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBREATH,NOBLOOD,RADIMMUNE,VIRUSIMMUNE)
	dangerous_existence = 1
	mutanteyes = /obj/item/organ/eyes/night_vision


/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()

		if(light_amount > 0.2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 0.2) //heal in the dark
			H.heal_overall_damage(1,1)
