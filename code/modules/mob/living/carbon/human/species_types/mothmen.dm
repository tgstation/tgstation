/datum/species/moth
	name = "Mothman"
	id = "moth"
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS, NOEYESPRITES, HAS_FLESH, HAS_BONE, HAS_MARKINGS, TRAIT_ANTENNAE)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list("moth_wings" = "Plain", "moth_antennae" = "Plain", "moth_markings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	wings_icons = list("Megamoth", "Mothra")
	has_innate_wings = TRUE
	payday_modifier = 0.75
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

/datum/species/moth/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE,list/excluded_zones)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		handle_mutant_bodyparts(H)

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	. = ..()
	if(.) //if the mob is immune to fire, don't burn wings off.
		return
	if(H.dna.features["moth_wings"] != "Burnt Off" && H.bodytemperature >= 800 && H.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "burnt_wings", /datum/mood_event/burnt_wings)
		if(!H.dna.features["original_moth_wings"]) //Fire apparently destroys DNA, so let's preserve that elsewhere, checks if an original was already stored to prevent bugs
			H.dna.features["original_moth_wings"] = H.dna.features["moth_wings"]
		H.dna.features["moth_wings"] = "Burnt Off"
		if(!H.dna.features["original_moth_antennae"]) //Stores antennae type for if they get restored later
			H.dna.features["original_moth_antennae"] = H.dna.features["moth_antennae"]
		H.dna.features["moth_antennae"] = "Burnt Off"
		if(flying_species) //This is all exclusive to if the person has the effects of a potion of flight
			if(H.movement_type & FLYING)
				ToggleFlight(H)
				H.Knockdown(1.5 SECONDS)
			fly.Remove(H)
			QDEL_NULL(fly)
			H.dna.features["wings"] = "None"
		handle_mutant_bodyparts(H)

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 10 //flyswatters deal 10x damage to moths
	return 1

/datum/species/moth/space_move(mob/living/carbon/human/H)
	. = ..()
	if(H.loc && !isspaceturf(H.loc) && H.dna.features["moth_wings"] != "Burnt Off" && !flying_species) //"flying_species" is exclusive to the potion of flight, which has its flying mechanics. If they want to fly they can use that instead
		var/datum/gas_mixture/current = H.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			return TRUE


/datum/species/moth/spec_fully_heal(mob/living/carbon/human/H)
	. = ..()
	if(H.dna.features["original_moth_wings"] != null)
		H.dna.features["moth_wings"] = H.dna.features["original_moth_wings"]

	if(H.dna.features["original_moth_wings"] == null && H.dna.features["moth_wings"] == "Burnt Off")
		H.dna.features["moth_wings"] = "Plain"

	if(H.dna.features["original_moth_antennae"] != null)
		H.dna.features["moth_antennae"] = H.dna.features["original_moth_antennae"]

	if(H.dna.features["original_moth_antennae"] == null && H.dna.features["moth_antennae"] == "Burnt Off")
		H.dna.features["moth_antennae"] = "Plain"
	handle_mutant_bodyparts(H)
