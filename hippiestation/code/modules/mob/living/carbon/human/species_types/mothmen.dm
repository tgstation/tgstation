/datum/species/moth
	name = "Mothmen"
	id = "moth"
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS, SPECIES_ORGANIC, NOEYES)
	mutant_bodyparts = list("moth_wings")
	default_features = list("moth_wings" = "Plain")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | DAIRY
	disliked_food = FRUIT | GROSS
	toxic_food = MEAT | RAW

/datum/species/moth/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!H.dna.features["moth_wings"])
			H.dna.features["moth_wings"] = "[(H.client && H.client.prefs && LAZYLEN(H.client.prefs.features) && H.client.prefs.features["moth_wings"]) ? H.client.prefs.features["moth_wings"] : "Plain"]"
			handle_mutant_bodyparts(H)
	C.grant_language(/datum/language/moth)

/datum/species/moth/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.remove_language(/datum/language/moth)

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/qualifies_for_rank(rank, list/features)
	if(CONFIG_GET(flag/enforce_human_authority) && (rank in GLOB.command_positions))
		return FALSE
	return TRUE

/datum/species/moth/handle_fire(mob/living/carbon/human/H, no_protection = FALSE)
	..()
	if(H.dna.features["moth_wings"] != "Burnt Off" && H.bodytemperature >= 800 && H.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
		H.dna.features["moth_wings"] = "Burnt Off"
		handle_mutant_bodyparts(H)

/datum/species/moth/check_roundstart_eligible()
	return TRUE
