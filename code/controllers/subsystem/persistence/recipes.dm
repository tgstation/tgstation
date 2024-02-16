///Loads all randomized recipes.
/datum/controller/subsystem/persistence/proc/load_randomized_recipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/json
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = new randomized_type
		var/loaded = FALSE
		if(R.persistent && json)
			var/list/recipe_data = json["[R.type]"]
			if(recipe_data)
				if(R.LoadOldRecipe(recipe_data) && (daysSince(R.created) <= R.persistence_period))
					loaded = TRUE
		if(!loaded) //We do not have information for whatever reason, just generate new one
			if(R.persistent)
				log_game("Resetting persistent [randomized_type] random recipe.")
			R.GenerateRecipe()

		if(!R.HasConflicts()) //Might want to try again if conflicts happened in the future.
			add_chemical_reaction(R)
		else
			log_game("Randomized recipe [randomized_type] resulted in conflicting recipes.")

///Saves all randomized recipes.
/datum/controller/subsystem/persistence/proc/save_randomized_recipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/list/file_data = list()

	//asert globchems done
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = get_chemical_reaction(randomized_type) //ew, would be nice to add some simple tracking
		if(R?.persistent)
			var/list/recipe_data = R.SaveOldRecipe()
			file_data["[R.type]"] = recipe_data

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
