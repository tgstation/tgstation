//Subtype of human
/datum/species/human/felinid
	name = "Felinid"
	id = SPECIES_FELINE
	say_mod = "meows"

	mutant_bodyparts = list("ears" = "Cat", "wings" = "None")

	mutantears = /obj/item/organ/internal/ears/cat
	external_organs = list(
		/obj/item/organ/external/tail/cat = "Cat",
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/felinid
	disliked_food = GROSS | CLOTH | RAW
	liked_food = SEAFOOD | ORANGES | BUGS
	var/original_felinid = TRUE //set to false for felinids created by mass-purrbation
	payday_modifier = 0.75
	ass_image = 'icons/ass/asscat.png'
	family_heirlooms = list(/obj/item/toy/cattoy)
	examine_limb_id = SPECIES_HUMAN

// Prevents felinids from taking toxin damage from carpotoxin
/datum/species/human/felinid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(istype(chem, /datum/reagent/toxin/carpotoxin))
		var/datum/reagent/toxin/carpotoxin/fish = chem
		fish.toxpwr = 0


/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load) //Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			H.dna.features["tail_cat"] = "Cat"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Cat"
		if(H.dna.features["ears"] == "Cat")
			var/obj/item/organ/internal/ears/cat/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/internal/ears
	return ..()

/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		return
	if(!isfelinid(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || isfelinid(H))
		return
	if(ishumanbasic(H))
		H.set_species(/datum/species/human/felinid)
		var/datum/species/human/felinid/cat_species = H.dna.species
		cat_species.original_felinid = FALSE
	else
		var/obj/item/organ/internal/ears/cat/kitty_ears = new
		var/obj/item/organ/external/tail/cat/kitty_tail = new
		kitty_ears.Insert(H, TRUE, FALSE) //Gives nonhumans cat tail and ears
		kitty_tail.Insert(H, TRUE, FALSE)
	if(!silent)
		to_chat(H, span_boldnotice("Something is nya~t right."))
		playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, TRUE, -1)

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(isfelinid(H))
		var/datum/species/human/felinid/cat_species = H.dna.species
		if(!cat_species.original_felinid)
			H.set_species(/datum/species/human)
	else if(ishuman(H) && !ishumanbasic(H))
		var/datum/species/target_species = H.dna.species
		for(var/obj/item/organ/current_organ as anything in H.external_organs)
			if(istype(current_organ, /obj/item/organ/external/tail/cat))
				current_organ.Remove(H, TRUE)
				var/obj/item/organ/external/tail/new_tail = locate(/obj/item/organ/external/tail) in target_species.external_organs
				if(new_tail)
					new_tail = new new_tail()
					new_tail.Insert(H, TRUE, FALSE)
			if(istype(current_organ, /obj/item/organ/internal/ears/cat))
				var/obj/item/organ/new_ears = new target_species.mutantears
				new_ears.Insert(H, TRUE, FALSE)
	if(!silent)
		to_chat(H, span_boldnotice("You are no longer a cat."))

/datum/species/human/felinid/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Hime Cut"
	human.hair_color = "#ffcccc" // pink
	human.update_hair(is_creating = TRUE)

	var/obj/item/organ/internal/ears/cat/cat_ears = human.getorgan(/obj/item/organ/internal/ears/cat)
	if (cat_ears)
		cat_ears.color = human.hair_color
		human.update_body()

/datum/species/human/felinid/get_species_description()
	return "Felinids are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Felinids are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Felinids are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

// Felinids are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/felinid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Grooming",
			SPECIES_PERK_DESC = "Felinids can lick wounds to reduce bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "Felinids are more sensitive to loud sounds, such as flashbangs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Felinids don't like getting soaked with water.",
		),
	)

	return to_add
