//Subtype of human
/datum/species/human/shark
	name = "Sharkperson"
	id = SPECIES_SHARK
	say_mod = "wehs"
	limbs_id = "human"

	mutant_bodyparts = list("tail_human" = "Shark", "wings" = "None")

	mutantears = /obj/item/organ/ears
	mutant_organs = list(/obj/item/organ/tail/shark)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/shark
	disliked_food = CLOTH | FRIED
	liked_food = RAW | MEAT | SEAFOOD
	payday_modifier = 0.75

/datum/species/human/shark/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/human/shark/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

// Prevents sharks from taking toxin damage from carpotoxin
/datum/species/human/shark/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(istype(chem, /datum/reagent/toxin/carpotoxin))
		var/datum/reagent/toxin/carpotoxin/fish = chem
		fish.toxpwr = 0

/datum/species/human/shark/can_wag_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["tail_human"] || mutant_bodyparts["waggingtail_human"]

/datum/species/human/shark/is_wagging_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["waggingtail_human"]

/datum/species/human/shark/start_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["tail_human"])
		mutant_bodyparts["waggingtail_human"] = mutant_bodyparts["tail_human"]
		mutant_bodyparts -= "tail_human"
	H.update_body()

/datum/species/human/shark/stop_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["waggingtail_human"])
		mutant_bodyparts["tail_human"] = mutant_bodyparts["waggingtail_human"]
		mutant_bodyparts -= "waggingtail_human"
	H.update_body()

/datum/species/human/shark/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		// Damn you kitsune code, too aggressive
		H.dna.features["ears"] = "Shark"
		var/obj/item/organ/ears/ears = new
		ears.Insert(H, drop_if_replaced = FALSE)

		if(H.dna.features["tail_human"] == "Shark")
			var/obj/item/organ/tail/shark/tail = new
			tail.Insert(H, special = TRUE, drop_if_replaced = FALSE)
		else
			mutant_organs = list()
	return ..()

/datum/species/human/shark/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Braid (Floorlength)"
	human.hair_color = "#fff389" // pink
	human.update_hair()

/datum/species/human/shark/get_species_description()
	return "Sharks. I don't know what to say about this. Domi held me at gunpoint, please send help."

/datum/species/human/shark/get_species_lore()
	return list(
		"I'm being threatened by Timberpoes and Domitius, they are holding me at a facility deep in a Canadian forest. I'm being forced \
		to code sharkgirls for them. Send help immediately.",
	)

// sharks are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/shark/create_pref_unique_perks()
	var/list/to_add = list()
	return to_add
