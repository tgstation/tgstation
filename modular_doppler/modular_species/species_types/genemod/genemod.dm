/mob/living/carbon/human/species/genemod
	race = /datum/species/human/genemod

/datum/species/human/genemod
	name = "Gene-Mod"
	id = SPECIES_GENEMOD
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_ANIMALISTIC,
		TRAIT_USES_SKINTONES,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/human/genemod/get_physical_attributes()
	return "N/a."

/datum/species/human/genemod/get_species_description()
	return "N/a."

/datum/species/human/genemod/get_species_lore()
	return list(
		"N/a.",
	)

/datum/species/human/genemod/on_species_gain(mob/living/carbon/human/target, datum/species/old_species, pref_load)
	apply_animal_trait(target, find_animal_trait(target))
	return ..()

/datum/species/human/genemod/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	// remember to make a puppygirl
	human_for_preview.set_haircolor("#3a2d22", update = FALSE)
	human_for_preview.set_hairstyle("Short twintails", update = TRUE)
	human_for_preview.update_body()
