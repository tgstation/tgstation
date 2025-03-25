/// Handles the assets for species icons
/datum/preference_middleware/species

/datum/preference_middleware/species/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/species),
	)

/datum/asset/spritesheet/species
	name = "species"
	early = TRUE

/datum/asset/spritesheet/species/create_spritesheets()
	var/list/to_insert = list()

	for (var/species_id in get_selectable_species())
		var/datum/species/species_type = GLOB.species_list[species_id]

		var/mob/living/carbon/human/dummy/consistent/dummy = new
		dummy.set_species(species_type)
		dummy.equipOutfit(/datum/outfit/job/assistant/consistent, visuals_only = TRUE)
		dummy.dna.species.prepare_human_for_preview(dummy)

		var/icon/dummy_icon = getFlatIcon(dummy)
		dummy_icon.Scale(64, 64)
		dummy_icon.Crop(15, 64 - 31, 15 + 31, 64)
		dummy_icon.Scale(64, 64)
		to_insert[sanitize_css_class_name(initial(species_type.name))] = dummy_icon

		SSatoms.prepare_deletion(dummy)

	for (var/spritesheet_key in to_insert)
		Insert(spritesheet_key, to_insert[spritesheet_key])

// Remove any invalid quirks by the species whitelist
/datum/preference_middleware/species/post_set_preference(mob/user, preference, value)
	. = ..()
	var/species_id = value // one of the options that this can be is species_id, but it can be other things as well annoyingly
	if(preference != "species" || !length(GLOB.quirk_species_whitelist) || !species_id)
		return .
	var/needs_update = FALSE
	for(var/quirk_name as anything in preferences.all_quirks)
		var/datum/quirk/quirk_type = SSquirks.quirks[quirk_name]
		var/list/species_whitelist = GLOB.quirk_species_whitelist[quirk_type]
		if(!length(species_whitelist) || (species_id in species_whitelist))
			continue
		preferences.all_quirks -= quirk_name
		needs_update = TRUE
	if(needs_update)
		preferences.update_static_data(user)
	return .
