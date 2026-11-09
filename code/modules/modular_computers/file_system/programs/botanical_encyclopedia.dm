/datum/computer_file/program/botanical_encyclopedia
	filename = "botanyapp"
	filedesc = "Botanical Encyclopedia"
	downloader_category = PROGRAM_CATEGORY_SERVICE
	program_open_overlay = "bountyboard"
	extended_desc = "A program for browsing knowledge about plants."
	size = 2
	tgui_id = "NtosBotanicalEncyclopedia"
	program_icon = FA_ICON_SEEDLING

	/// Lazy list of all seed data for valid seed types.
	/// Generated when first needed to display the UI.
	var/static/list/all_seed_data = null

/datum/computer_file/program/botanical_encyclopedia/proc/generate_all_seed_data()
	all_seed_data = list()

	for(var/obj/item/seeds/seed_type as anything in valid_subtypesof(/obj/item/seeds))
		if (ispath(seed_type, /obj/item/seeds/random))
			continue

		var/obj/item/seeds/seeds = new seed_type

		var/list/seed_data = generate_seed_data_from(seeds)

		seed_data["name"] = full_capitalize(initial(seed_type.plantname))
		seed_data["icon"] = initial(seed_type.growing_icon)
		seed_data["icon_state"] = initial(seed_type.icon_harvest) || "[initial(seed_type.species)]-harvest"

		all_seed_data += list(seed_data)

		qdel(seeds)

/datum/computer_file/program/botanical_encyclopedia/ui_static_data(mob/user)
	if(isnull(all_seed_data))
		generate_all_seed_data()

	var/list/data = list()

	data["seeds"] = all_seed_data
	data["cycle_seconds"] = HYDROTRAY_CYCLE_DELAY / 10
	data["trait_db"] = list()

	for(var/datum/plant_gene/trait as anything in GLOB.plant_traits)
		data["trait_db"] += list(list(
			"path" = trait.type,
			"name" = trait.get_name(),
			"icon" = trait.icon,
			"description" = trait.description
		))

	return data
