/mob/living/carbon/human/species/genemod
	race = /datum/species/human/genemod

/datum/species/human/genemod
	name = "Gene-Mod"
	id = SPECIES_GENEMOD
	preview_outfit = /datum/outfit/genemod_preview
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_ANIMALISTIC,
		TRAIT_MUTANT_COLORS,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/genemod,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/genemod,
	)

/datum/outfit/genemod_preview
	name = "Gene-Mod (Species Preview)"
	uniform = /obj/item/clothing/under/dress/sundress

/datum/species/human/genemod/get_physical_attributes()
	return "N/a."

/datum/species/human/genemod/get_species_description()
	return "N/a."

/datum/species/human/genemod/get_species_lore()
	return list(
		"N/a.",
	)

/datum/species/human/genemod/on_species_gain(mob/living/carbon/human/target, datum/species/old_species, pref_load, regenerate_icons)
	apply_animal_trait(target, find_animal_trait(target))
	return ..()

/datum/species/human/genemod/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.ear_type = DOG
	human_for_preview.dna.features["ears"] = "Fold"
	human_for_preview.dna.features["ears_color_1"] = "#4E3E30"
	human_for_preview.dna.features["ears_color_2"] = "#F4B1C8"
	human_for_preview.set_haircolor("#3a2d22", update = FALSE)
	human_for_preview.set_hairstyle("Short twintails", update = TRUE)
	human_for_preview.dna.features["mcolor"] = skintone2hex("mixed3")
	human_for_preview.eye_color_left = "#442B12"
	human_for_preview.eye_color_right = "#442B12"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)
