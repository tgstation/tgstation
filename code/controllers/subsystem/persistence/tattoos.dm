///Loads all tattoos, and select a few based on the amount of prisoner spawn positions.
/datum/controller/subsystem/persistence/proc/load_prisoner_tattoos()
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < TATTOO_PERSISTENCE_VERSION)
		update_prisoner_tattoos(json)

	var/datum/job/prisoner_datum = SSjob.name_occupations[JOB_PRISONER]
	if(!prisoner_datum)
		return
	var/iterations_allowed = prisoner_datum.spawn_positions

	var/list/entries = json["entries"]
	if(entries.len)
		for(var/index in 1 to iterations_allowed)
			prison_tattoos_to_use += list(entries[rand(1, entries.len)])

	log_world("Loaded [prison_tattoos_to_use.len] prison tattoos")

///Saves all tattoos, so they can appear on prisoners in future rounds
/datum/controller/subsystem/persistence/proc/save_prisoner_tattoos()
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	var/list/saved_data = list()
	var/list/entries = list()

	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			entries += old_json["entries"]  //Save the old if its there

	entries += prison_tattoos_to_save

	saved_data["version"] = ENGRAVING_PERSISTENCE_VERSION
	saved_data["entries"] = entries

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(saved_data))

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_prisoner_tattoos(json)
	for(var/tattoo_entry in json["entries"])
		continue //no versioning yet

	//Save it to the file
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json

