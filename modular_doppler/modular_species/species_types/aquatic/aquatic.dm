/mob/living/carbon/human/species/aquatic
	race = /datum/species/aquatic

/datum/species/aquatic
	name = "\improper Aquatic"
	plural_form = "Aquatic"
	id = SPECIES_AQUATIC
	preview_outfit = /datum/outfit/aquatic_preview
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "Aquatic Pattern")
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/aquatic,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/aquatic,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/aquatic,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/aquatic,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/aquatic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/aquatic,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/aquatic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/aquatic,
	)

/datum/outfit/aquatic_preview
	name = "Aquatic (Species Preview)"
	uniform = /obj/item/clothing/under/syndicate/skirt
	head = /obj/item/clothing/head/hats/hos/beret/syndicate

/datum/species/aquatic/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features["lizard_markings"] = "Aquatic Pattern"
	human_for_preview.dna.features["body_markings_color_1"] = "#ffffff"
	human_for_preview.dna.features["mcolor"] = "#C2756A"
	human_for_preview.dna.features["snout"] = "Shark"
	human_for_preview.dna.features["snout_color_1"] = "#ffffff"
	human_for_preview.dna.features["snout_color_2"] = "#c2756a"
	human_for_preview.dna.ear_type = FISH
	human_for_preview.dna.features["ears"] = "Shark"
	human_for_preview.dna.features["ears_color_1"] = "#C2756A"
	human_for_preview.dna.features["ears_color_2"] = "#FCB39F"
	human_for_preview.set_haircolor("#221711", update = FALSE)
	human_for_preview.set_hairstyle("Blunt Bangs", update = TRUE)
	human_for_preview.eye_color_left = "#77B077"
	human_for_preview.eye_color_right = "#77B077"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/datum/species/aquatic/get_species_description()
	return "Nothing yet."

/datum/species/aquatic/get_species_lore()
	return list(
		"Nothing yet.",
	)
