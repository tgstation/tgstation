/// Handles the assets for species icons
/datum/preference_middleware/species

/datum/preference_middleware/species/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/species),
	)

/datum/asset/spritesheet_batched/species
	name = "species"
	early = TRUE

/datum/asset/spritesheet_batched/species/create_spritesheets()
	for (var/species_id in get_selectable_species())
		var/datum/species/species_type = GLOB.species_list[species_id]

		var/mob/living/carbon/human/dummy/consistent/dummy = new
		dummy.set_species(species_type)
		dummy.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
		dummy.dna.species.prepare_human_for_preview(dummy)

		var/datum/universal_icon/dummy_icon = get_flat_uni_icon(dummy)
		dummy_icon.scale(64, 64)
		dummy_icon.crop(15, 64 - 31, 15 + 31, 64)
		dummy_icon.scale(64, 64)
		insert_icon(sanitize_css_class_name(initial(species_type.name)), dummy_icon)

		SSatoms.prepare_deletion(dummy)
