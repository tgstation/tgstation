/// Handles the assets for species icons
/datum/preference_middleware/species

/datum/preference_middleware/species/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/species),
	)

/datum/asset/spritesheet/species
	name = "species"
	early = TRUE
	cross_round_cachable = TRUE

/datum/asset/spritesheet/species/create_spritesheets()
	for (var/species_id in get_selectable_species())
		var/datum/species/species_type = GLOB.species_list[species_id]

		var/mob/living/carbon/human/dummy/consistent/dummy = new
		dummy.set_species(species_type)
		dummy.equipOutfit(/datum/outfit/job/assistant/consistent, visualsOnly = TRUE)
		dummy.dna.species.prepare_human_for_preview(dummy)

		var/icon/dummy_icon = getFlatIcon(dummy)
		dummy_icon.Scale(64, 64)
		dummy_icon.Crop(15, 64, 15 + 31, 64 - 31)
		dummy_icon.Scale(64, 64)
		var/spritesheet_key = sanitize_css_class_name(initial(species_type.name))

		SSatoms.prepare_deletion(dummy)

		Insert(spritesheet_key, dummy_icon)
