/datum/computer_file/program/botanical_encyclopedia
    filename = "botanyapp"
    filedesc = "Botanical Encyclopedia"
    downloader_category = PROGRAM_CATEGORY_SERVICE
    program_open_overlay = "bountyboard"
    extended_desc = "A program for browsing knowledge about plants."
    size = 2
    tgui_id = "NtosBotanicalEncyclopedia"
    program_icon = FA_ICON_SEEDLING

/datum/computer_file/program/botanical_encyclopedia/ui_data(mob/user)
	return list("seeds" = GLOB.botany_seed_infos)

// TODO: Extract this to a global list and share it with the seed extractor.
/datum/computer_file/program/botanical_encyclopedia/ui_static_data(mob/user)
	var/list/data = list()
	data["cycle_seconds"] = HYDROTRAY_CYCLE_DELAY / 10
	data["trait_db"] = list()
	for(var/datum/plant_gene/trait as anything in GLOB.plant_traits)
		var/trait_data = list(list(
			"path" = trait.type,
			"name" = trait.get_name(),
			"icon" = trait.icon,
			"description" = trait.description
		))
		data["trait_db"] += trait_data
	return data
