/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	blacklisted = 1
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBREATH,NOBLOOD,RADIMMUNE,VIRUSIMMUNE)
	dangerous_existence = 1
	var/datum/action/innate/shadow/darkvision/vision_toggle

/datum/action/innate/shadow/darkvision //Darkvision toggle so shadowpeople can actually see where darkness is
	name = "Toggle Darkvision"
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_default"
	button_icon_state = "blind"

/datum/action/innate/shadow/darkvision/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.see_in_dark < 8)
		H.see_in_dark = 8
		H.see_invisible = SEE_INVISIBLE_MINIMUM
		H << "<span class='notice'>You adjust your vision to pierce the darkness.</span>"
	else
		H.see_in_dark = 2
		H.see_invisible = SEE_INVISIBLE_LIVING
		H << "<span class='notice'>You adjust your vision to recognize the shadows.</span>"

/datum/species/shadow/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	vision_toggle = new
	vision_toggle.Grant(C)

/datum/species/shadow/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(vision_toggle)
		vision_toggle.Remove(C)

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)