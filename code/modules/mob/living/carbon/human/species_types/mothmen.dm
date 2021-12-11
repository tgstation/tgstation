/datum/species/moth
	name = "Mothman"
	id = SPECIES_MOTH
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS, HAS_FLESH, HAS_BONE, HAS_MARKINGS, TRAIT_ANTENNAE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list("moth_markings" = "None")
	external_organs = list(/obj/item/organ/external/wings/moth = "Plain", /obj/item/organ/external/antennae = "Plain")
	attack_verb = "slash"
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS
	toxic_food = MEAT | RAW | SEAFOOD
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	wings_icons = list("Megamoth", "Mothra")
	has_innate_wings = TRUE
	payday_modifier = 0.75
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

/datum/species/moth/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current= TRUE, list/excluded_zones, visual_only)
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

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 10 //flyswatters deal 10x damage to moths
	return 1

/datum/species/moth/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	var/wings = pick(GLOB.moth_wings_list)
	mutant_bodyparts["wings"] = wings
	mutant_bodyparts["moth_wings"] = wings
	human_mob.dna.features["wings"] = wings
	human_mob.dna.features["moth_wings"] = wings
	human_mob.update_body()

/datum/species/moth/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/voice/moth/scream_moth.ogg'
