/datum/species/moth
	preview_outfit = /datum/outfit/moth_preview

/datum/outfit/moth_preview
	name = "Moth (Species Preview)"
	head = /obj/item/clothing/head/costume/garland/poppy
	suit = /obj/item/clothing/suit/hooded/wintercoat/hydro
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics/skirt

/datum/species/moth/prepare_human_for_preview(mob/living/carbon/human/moth_for_preview)
	moth_for_preview.dna.wing_type = "Moth Wings"
	moth_for_preview.dna.features["moth_wings"] = "Royal"
	moth_for_preview.dna.features["moth_antennae"] = "Royal"
	moth_for_preview.dna.features["moth_markings"] = "Royal"
	moth_for_preview.set_haircolor("#CCECFF", update = FALSE)
	moth_for_preview.set_hairstyle("Cotton (Alt)", update = TRUE)
	regenerate_organs(moth_for_preview)
	moth_for_preview.update_body(is_creating = TRUE)
