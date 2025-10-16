#define REAGENT_EXPORTER_JSON_PATH "data/reagent_tool/exported_reagents.json"

/client/verb/export_reagents()
	set category = "Custom"
	set name = "Export Reagents"

	var/list/datum/reagent/all_reagent_types = subtypesof(/datum/reagent)
	var/list/reagents_data = list()

	for (var/datum/reagent/reagent_type as anything in all_reagent_types)
		var/list/reagent_data = list()
		reagent_data["name"] = initial(reagent_type.name)
		reagent_data["ph"] = initial(reagent_type.ph)

		reagents_data += list(reagent_data)

	var/list/datum/chemical_reaction/all_reactions = GLOB.chemical_reactions_list
	var/list/reactions_data = list()

	for (var/reaction_type as anything in all_reactions)
		var/datum/chemical_reaction/reaction = all_reactions[reaction_type]

		var/list/reaction_data = list()
		reaction_data["products"] = reaction.results
		reaction_data["ingredients"] = reaction.required_reagents
		reaction_data["catalysts"] = reaction.required_catalysts

		reactions_data += list(reaction_data)

	var/list/json_data = list()
	json_data["reagents"] = reagents_data
	json_data["reactions"] = reactions_data

	rustg_file_write(json_encode(json_data, JSON_PRETTY_PRINT), REAGENT_EXPORTER_JSON_PATH)

#undef REAGENT_EXPORTER_JSON_PATH
