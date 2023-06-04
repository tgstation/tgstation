/// Handles the assets for species icons and ensuring quirks are compatible with species we change into.
/datum/preference_middleware/species

/datum/preference_middleware/species/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/species),
	)

//We only come into effect if our pref key (species) is changed.
//We will filter invalid quirks. If it is cancelled out then we will not change anything and not allow the change through.
//Otherwise we will accept the incoming changes and change the species.
/datum/preference_middleware/species/pre_set_preference(mob/user, requested_preference_key, value)
	if(requested_preference_key != SAVEFILE_KEY_NAME_SPECIES)
		return FALSE
	var/quirk_response = SSquirks.filter_invalid_quirks(SANITIZE_LIST(preferences.all_quirks), preferences, species_type = GLOB.species_list[value], give_warning = TRUE)
	if(!quirk_response)
		return TRUE
	if(preferences.all_quirks != quirk_response)
		preferences.all_quirks = quirk_response
		preferences.update_static_data(user)
	return FALSE

/datum/asset/spritesheet/species
	name = SAVEFILE_KEY_NAME_SPECIES
	early = TRUE
	cross_round_cachable = TRUE

/datum/asset/spritesheet/species/create_spritesheets()
	var/list/to_insert = list()

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
		to_insert[sanitize_css_class_name(initial(species_type.name))] = dummy_icon

		SSatoms.prepare_deletion(dummy)

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])
