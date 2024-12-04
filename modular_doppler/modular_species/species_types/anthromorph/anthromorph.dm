/mob/living/carbon/human/species/anthromorph
	race = /datum/species/anthromorph

/datum/species/anthromorph
	name = "\improper Anthromorph"
	plural_form = "Anthromorphic"
	id = SPECIES_ANTHROMORPH
	preview_outfit = /datum/outfit/anthro_preview
	inherent_traits = list(
		TRAIT_ANIMALISTIC,
		TRAIT_MUTANT_COLORS,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "Anthromorph Pattern")
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/anthromorph,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/anthromorph,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/anthromorph,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/anthromorph,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/anthromorph,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/anthromorph,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/anthromorph,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/anthromorph,
	)

/datum/species/anthromorph/on_species_gain(mob/living/carbon/human/target, datum/species/old_species, pref_load, regenerate_icons)
	apply_animal_trait(target, find_animal_trait(target))
	return ..()

/datum/outfit/anthro_preview
	name = "Anthromorph (Species Preview)"
	uniform = /obj/item/clothing/under/rank/security/officer/skirt

/datum/species/anthromorph/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features["mcolor"] = "#776155"
	human_for_preview.dna.features["snout"] = "Fox (Long)"
	human_for_preview.dna.features["snout_color_2"] = "#ffffff"
	human_for_preview.dna.features["snout_color_3"] = "#776155"
	human_for_preview.dna.ear_type = FOX
	human_for_preview.dna.features["ears"] = "Fox"
	human_for_preview.dna.features["ears_color_1"] = "#776155"
	human_for_preview.dna.features["ears_color_2"] = "#ffffff"
	human_for_preview.set_haircolor("#574036", update = FALSE)
	human_for_preview.set_hairstyle("Stacy Bun", update = TRUE)
	human_for_preview.eye_color_left = "#C4F87A"
	human_for_preview.eye_color_right = "#C4F87A"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/datum/species/anthromorph/get_species_description()
	return "Nothing yet."

/datum/species/anthromorph/get_species_lore()
	return list(
		"Nothing yet.",
	)
