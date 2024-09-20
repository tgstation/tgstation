/datum/species/lizard
	preview_outfit = /datum/outfit/lizard_preview

/datum/outfit/lizard_preview
	name = "Lizardperson (Species Preview)"
	head = /obj/item/clothing/head/beret/doppler_command/medical
	neck = /obj/item/clothing/neck/doppler_mantle/medical

/datum/species/lizard/prepare_human_for_preview(mob/living/carbon/human/lizard_for_preview)
	lizard_for_preview.dna.features["mcolor"] = "#4A81A1"
	lizard_for_preview.dna.features["frills"] = "Short"
	lizard_for_preview.dna.features["frills_color_1"] = "#4a81a1"
	lizard_for_preview.dna.features["frills_color_2"] = "#c6c7d3"
	regenerate_organs(lizard_for_preview)
	lizard_for_preview.update_body(is_creating = TRUE)
