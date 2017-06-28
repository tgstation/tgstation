/datum/species/moth
	// Shitty moths, why do we need them dammit
	name = "Mothmen"
	id = "moth"
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS)
	mutant_bodyparts = list("moth_wings")
	default_features = list("moth_wings" = "Plain")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	roundstart = TRUE
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/moth

/datum/species/moth/on_species_gain(mob/living/carbon/human/C)
	C.draw_hippie_parts()
	. = ..()

/datum/species/moth/on_species_loss(mob/living/carbon/human/C)
	C.draw_hippie_parts(TRUE)
	. = ..()

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name(gender)

	var/randname = moth_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.command_positions)
		return 0
	return 1
