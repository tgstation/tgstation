///trophy data datum, for admin manipulation
/datum/trophy_data
	///path of the item the trophy will try to mimic, null if path_string is invalid
	var/path
	///the message that appears under the item
	var/message
	///the key of the one who placed the item in the trophy case
	var/placer_key

/// Loads the trophies from the source file, and places a few in trophy display cases.
/datum/controller/subsystem/persistence/proc/load_trophies()
	var/list/raw_saved_trophies = list()
	if(fexists("data/npc_saves/TrophyItems.json"))
		var/json_file = file("data/npc_saves/TrophyItems.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		if(!json)
			return
		raw_saved_trophies = json["data"]
		fdel("data/npc_saves/TrophyItems.json")
	else
		var/json_file = file("data/trophy_items.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		if(!json)
			return
		raw_saved_trophies = json["data"]

	for(var/raw_json in raw_saved_trophies)
		var/datum/trophy_data/parsed_trophy_data = new
		parsed_trophy_data.load_from_json(raw_json)
		saved_trophies += parsed_trophy_data

	set_up_trophies()

/datum/trophy_data/proc/load_from_json(list/json_data)
	path = json_data["path"]
	message = json_data["message"]
	placer_key = json_data["placer_key"]

/datum/trophy_data/proc/to_json()
	var/list/new_data = list()
	new_data["path"] = path
	new_data["message"] = message
	new_data["placer_key"] = placer_key
	new_data["is_valid"] = text2path(path) ? TRUE : FALSE
	return new_data

/// Returns a list for the admin trophy panel.
/datum/controller/subsystem/persistence/proc/trophy_ui_data()
	var/list/ui_data = list()
	for(var/datum/trophy_data/data in saved_trophies)
		var/list/pdata = data.to_json()
		pdata["ref"] = REF(data)
		ui_data += list(pdata)

	return ui_data


/// Puts trophies into trophy cases.
/datum/controller/subsystem/persistence/proc/set_up_trophies()

	var/list/valid_trophies = list()

	for(var/datum/trophy_data/data in saved_trophies)

		if(!data) //sanity for incorrect deserialization
			continue

		var/path = text2path(data.path)
		if(!path) //If the item no longer exist, ignore it
			continue

		valid_trophies += data

	for(var/obj/structure/displaycase/trophy/trophy_case in GLOB.trophy_cases)
		if(!valid_trophies.len)
			break

		if(trophy_case.showpiece)
			continue

		trophy_case.set_up_trophy(pick_n_take(valid_trophies))

///Collects trophies from all existing trophy cases.
/datum/controller/subsystem/persistence/proc/collect_trophies()
	for(var/trophy_case in GLOB.trophy_cases)
		save_trophy(trophy_case)

	var/json_file = file("data/trophy_items.json")
	var/list/file_data = list()
	var/list/converted_data = list()

	for(var/datum/trophy_data/data in saved_trophies)
		converted_data += list(data.to_json())

	converted_data = remove_duplicate_trophies(converted_data)

	file_data["data"] = converted_data
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///gets the list of json trophies, and deletes the ones with an identical path and message
/datum/controller/subsystem/persistence/proc/remove_duplicate_trophies(list/trophies)
	var/list/ukeys = list()
	. = list()
	for(var/trophy in trophies)
		var/tkey = "[trophy["path"]]-[trophy["message"]]"
		if(ukeys[tkey])
			continue
		else
			. += list(trophy)
			ukeys[tkey] = TRUE

///If there is a trophy in the trophy case, saved it, if the trophy was not a holo trophy and has a message attached.
/datum/controller/subsystem/persistence/proc/save_trophy(obj/structure/displaycase/trophy/trophy_case)
	if(!trophy_case.holographic_showpiece && trophy_case.showpiece && trophy_case.trophy_message)
		var/datum/trophy_data/data = new
		data.path = trophy_case.showpiece.type
		data.message = trophy_case.trophy_message
		data.placer_key = trophy_case.placer_key
		saved_trophies += data

