///Saves all randomized recipes.
/datum/controller/subsystem/persistence/proc/save_randomized_recipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/list/file_data = list()

	//asert globchems done
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = GLOB.chemical_reactions_list[randomized_type]
		if(!R)
			continue
		file_data["[R.type]"] = list(
			timestamp = R.created,
			required_reagents = R.required_reagents,
			required_catalysts = R.required_catalysts,
			is_cold_recipe = R.is_cold_recipe,
			required_temp = R.required_temp,
			optimal_temp = R.optimal_temp,
			overheat_temp = R.overheat_temp,
			thermic_constant = R.thermic_constant,
			optimal_ph_min = R.optimal_ph_min,
			optimal_ph_max = R.optimal_ph_max,
			determin_ph_range = R.determin_ph_range,
			H_ion_release = R.H_ion_release,
			purity_min = R.purity_min,
			results = R.results,
			required_container = R.required_container
		)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
