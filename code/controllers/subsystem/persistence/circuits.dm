#define CIRCUITS_DATA_FILEPATH "data/circuit_designs/"

/datum/controller/subsystem/persistence/proc/load_circuits_by_ckey(user)
	var/json_file = file("[CIRCUITS_DATA_FILEPATH][user].json")
	if(!fexists(json_file))
		circuit_designs[user] = list()
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		circuit_designs[user] = list()
		return
	var/list/new_circuit_designs = json["data"]
	for (var/list/design in new_circuit_designs)
		var/list/new_materials = list()
		for (var/material in design["materials"])
			new_materials[GET_MATERIAL_REF(text2path(material))] = design["materials"][material]
		design["materials"] = new_materials
	circuit_designs[user] = new_circuit_designs

/datum/controller/subsystem/persistence/proc/save_circuits()
	for (var/user in circuit_designs)
		var/json_file = file("[CIRCUITS_DATA_FILEPATH][user].json")
		var/file_data = list()
		var/list/user_designs = circuit_designs[user]
		var/list/designs_to_store = user_designs.Copy()

		for (var/list/design in designs_to_store)
			var/list/new_materials = list()
			for (var/datum/material/material in design["materials"])
				new_materials["[material.type]"] = design["materials"][material]
			design["materials"] = new_materials

		file_data["data"] = designs_to_store
		fdel(json_file)
		WRITE_FILE(json_file, json_encode(file_data))

#undef CIRCUITS_DATA_FILEPATH
