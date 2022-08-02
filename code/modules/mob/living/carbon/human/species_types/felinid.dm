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


/datum/species/human/felinid/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load)
	if(ishuman(carbon_being))
		var/mob/living/carbon/human/target_human = carbon_being
		if(!pref_load) //Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			target_human.dna.features["tail_cat"] = "Cat"
			if(target_human.dna.features["ears"] == "None")
				target_human.dna.features["ears"] = "Cat"
		if(target_human.dna.features["ears"] == "Cat")
			var/obj/item/organ/internal/ears/cat/ears = new
			ears.Insert(target_human, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/internal/ears
	return ..()

/proc/mass_purrbation()
	for(var/mob in GLOB.human_list)
		purrbation_apply(mob)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/mob in GLOB.human_list)
		purrbation_remove(mob)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/target_human, silent = FALSE)
	if(!ishuman(target_human))
		return
	if(!istype(target_human.getorganslot(ORGAN_SLOT_EARS), /obj/item/organ/internal/ears/cat))
		purrbation_apply(target_human, silent = silent)
		. = TRUE
	else
		purrbation_remove(target_human, silent = silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/soon_to_be_felinid, silent = FALSE)
	if(!ishuman(soon_to_be_felinid) || isfelinid(soon_to_be_felinid))
		return
	if(ishumanbasic(soon_to_be_felinid))
		soon_to_be_felinid.set_species(/datum/species/human/felinid)
		var/datum/species/human/felinid/cat_species = soon_to_be_felinid.dna.species
		cat_species.original_felinid = FALSE
	else
		var/obj/item/organ/internal/ears/cat/kitty_ears = new
		var/obj/item/organ/external/tail/cat/kitty_tail = new
		kitty_ears.Insert(soon_to_be_felinid, special = TRUE, drop_if_replaced = FALSE) //Gives nonhumans cat tail and ears
		kitty_tail.Insert(soon_to_be_felinid, special = TRUE, drop_if_replaced = FALSE)
	if(!silent)
		to_chat(soon_to_be_felinid, span_boldnotice("Something is nya~t right."))
		playsound(get_turf(soon_to_be_felinid), 'sound/effects/meow1.ogg', 50, TRUE, -1)

/proc/purrbation_remove(mob/living/carbon/human/purrbated_human, silent = FALSE)
	if(isfelinid(purrbated_human))
		var/datum/species/human/felinid/cat_species = purrbated_human.dna.species
		if(cat_species.original_felinid)
			return // Don't display the to_chat message
		purrbated_human.set_species(/datum/species/human)
	else if(ishuman(purrbated_human) && !ishumanbasic(purrbated_human))
		var/datum/species/target_species = purrbated_human.dna.species

		// From the previous check we know they're not a felinid, therefore removing cat ears and tail is safe
		var/obj/item/organ/external/tail/old_tail = purrbated_human.getorganslot(ORGAN_SLOT_EXTERNAL_TAIL)
		if(istype(old_tail, /obj/item/organ/external/tail/cat))
			var/obj/item/organ/external/tail/new_tail = locate(/obj/item/organ/external/tail) in target_species.external_organs
			if(new_tail)
				new_tail = new new_tail()
				new_tail.Insert(purrbated_human, special = TRUE, drop_if_replaced = FALSE)
			else
				old_tail.Remove(purrbated_human, special = TRUE)
				qdel(old_tail)

		var/obj/item/organ/internal/ears/old_ears = purrbated_human.getorganslot(ORGAN_SLOT_EARS)
		if(istype(old_ears, /obj/item/organ/internal/ears/cat))
			var/obj/item/organ/new_ears = new target_species.mutantears()
			new_ears.Insert(purrbated_human, special = TRUE, drop_if_replaced = FALSE)
	if(!silent)
		to_chat(purrbated_human, span_boldnotice("You are no longer a cat."))

/datum/species/human/felinid/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.hairstyle = "Hime Cut"
	human_for_preview.hair_color = "#ffcccc" // pink
	human_for_preview.update_hair(is_creating = TRUE)

	var/obj/item/organ/internal/ears/cat/cat_ears = human_for_preview.getorgan(/obj/item/organ/internal/ears/cat)
	if (cat_ears)
		cat_ears.color = human_for_preview.hair_color
		human_for_preview.update_body()

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
