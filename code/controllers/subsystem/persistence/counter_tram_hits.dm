/// Location where we save the information about how many times the tram hit on previous round
#define TRAM_COUNT_FILEPATH "data/tram_hits_last_round.txt"
#define MAX_TRAM_SAVES 4

// Loads historical tram data
/datum/controller/subsystem/persistence/proc/load_tram_history(specific_transport_id)
	var/list/raw_saved_trams = list()
	var/json_file = file("data/tram_data/[specific_transport_id].json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return
	raw_saved_trams = json["data"]

	var/list/previous_tram_data = list()
	for(var/raw_json in raw_saved_trams)
		var/datum/tram_mfg_info/parsed_tram_data = new
		parsed_tram_data.load_from_json(raw_json)
		previous_tram_data += parsed_tram_data
	return previous_tram_data

// Saves historical tram data
/datum/controller/subsystem/persistence/proc/save_tram_history(specific_transport_id)
	var/list/packaged_tram_data = list()
	for(var/datum/transport_controller/linear/tram/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(transport.specific_transport_id == specific_transport_id)
			packaged_tram_data = package_tram_data(transport)
			break

	var/json_file = file("data/tram_data/[specific_transport_id].json")
	var/list/file_data = list()
	var/list/converted_data = list()

	for(var/datum/tram_mfg_info/data in packaged_tram_data)
		converted_data += list(data.export_to_json())

	file_data["data"] = converted_data
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/package_tram_data(datum/transport_controller/linear/tram/tram_controller)
	var/list/packaged_data = list()
	var/list/tram_list = tram_controller.tram_history
	if(!isnull(tram_list))
		while(tram_list.len > MAX_TRAM_SAVES)
			tram_list.Cut(1,2)

		for(var/datum/tram_mfg_info/data as anything in tram_list)
			packaged_data += data

	packaged_data += tram_controller.tram_registration
	return packaged_data

/datum/controller/subsystem/persistence/proc/load_tram_counter()
	if(!fexists(TRAM_COUNT_FILEPATH))
		return
	tram_hits_last_round = text2num(file2text(TRAM_COUNT_FILEPATH))

/datum/controller/subsystem/persistence/proc/save_tram_counter()
	rustg_file_write("[tram_hits_this_round]", TRAM_COUNT_FILEPATH)

#undef TRAM_COUNT_FILEPATH
#undef MAX_TRAM_SAVES
