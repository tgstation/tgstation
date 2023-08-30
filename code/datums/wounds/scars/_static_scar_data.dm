GLOBAL_LIST_INIT_TYPED(all_static_scar_data, /datum/static_scar_data, generate_static_scar_data())

/proc/generate_static_scar_data()
	RETURN_TYPE(/list/datum/static_scar_data)

	var/list/datum/wound_pregen_data/data = list()

	for (var/datum/wound_pregen_data/path as anything in typecacheof(path = /datum/static_scar_data, ignore_root_path = TRUE))
		if (initial(path.abstract))
			continue

		var/datum/wound_pregen_data/pregen_data = new path
		data[pregen_data.wound_path_to_generate] = pregen_data

	return data

/datum/static_scar_data
	var/abstract = FALSE


