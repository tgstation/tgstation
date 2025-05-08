/mob/living/carbon/human/species/insectoid
	race = /datum/species/insectoid

/datum/species/insectoid
	name = "\improper Insectoid"
	plural_form = "Insectoid"
	id = SPECIES_INSECTOID
	preview_outfit = /datum/outfit/insect_preview
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_WEB_WEAVER,
		TRAIT_WEB_SURFER,
	)
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "Insectoid Pattern")
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	payday_modifier = 1.0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	exotic_blood = /datum/reagent/bug_blood
	exotic_bloodtype = BLOOD_TYPE_INSECTOID

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/insectoid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/insectoid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/insectoid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/insectoid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/insectoid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/insectoid,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/insectoid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/insectoid,
	)
	mutanteyes = /obj/item/organ/eyes/bug
	mutanttongue = /obj/item/organ/tongue/bug
	mutantstomach = /obj/item/organ/stomach/roach
	mutantliver = /obj/item/organ/liver/roach
	mutantappendix = /obj/item/organ/appendix/roach

/datum/outfit/insect_preview
	name = "Insectoid (Species Preview)"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland

/datum/species/insectoid/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.dna.features["lizard_markings"] = "Insectoid Pattern"
	human_for_preview.dna.features["body_markings_color_1"] = "#46c346"
	human_for_preview.dna.features["body_markings_color_2"] = "#1c1c1c"
	human_for_preview.dna.features["mcolor"] = "#383942"
	human_for_preview.dna.features["fluff"] = "Insect Fluff"
	human_for_preview.dna.features["fluff_color_1"] = "#dae7f7"
	human_for_preview.dna.ear_type = BUG
	human_for_preview.dna.features["ears"] = "Straight"
	human_for_preview.dna.features["ears_color_1"] = "#ffffff"
	human_for_preview.eye_color_left = "#46C346"
	human_for_preview.eye_color_right = "#46C346"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/datum/species/insectoid/get_species_description()
	return "Nothing yet."

/datum/species/insectoid/get_species_lore()
	return list(
		"Nothing yet.",
	)
