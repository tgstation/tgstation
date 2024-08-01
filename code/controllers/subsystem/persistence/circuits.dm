#define CIRCUITS_DATA_FILEPATH "data/circuit_designs.json"

/datum/controller/subsystem/persistence/proc/load_circuits()
	var/json_file = file(CIRCUITS_DATA_FILEPATH)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return
	circuit_designs = json["data"]
	for (var/list/design in circuit_designs)
		var/list/new_materials = list()
		for (var/material in design["materials"])
			new_materials[GET_MATERIAL_REF(text2path(material))] = design["materials"][material]
		design["materials"] = new_materials

/datum/controller/subsystem/persistence/proc/save_circuits()
	var/json_file = file(CIRCUITS_DATA_FILEPATH)
	var/file_data = list()
	var/designs_to_store = circuit_designs.Copy()

	for (var/list/design in designs_to_store)
		var/list/new_materials = list()
		for (var/datum/material/material in design["materials"])
			new_materials["[material.type]"] = design["materials"][material]
		design["materials"] = new_materials

	file_data["data"] = designs_to_store
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

#undef CIRCUITS_DATA_FILEPATH
