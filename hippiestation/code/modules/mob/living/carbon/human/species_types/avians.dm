/datum/species/bird
	// flappy bird
	name = "Avian"
	id = "avian"
	say_mod = "squawks"
	default_color = "00FF00"
	blacklisted = 0
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS)
	attack_verb = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/bird

/datum/species/bird/on_species_gain(mob/living/carbon/human/C)
	C.draw_hippie_parts()
	. = ..()

/datum/species/bird/on_species_loss(mob/living/carbon/human/C)
	C.draw_hippie_parts(TRUE)
	. = ..()