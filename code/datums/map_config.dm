//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	// Metadata
	var/config_filename = "_maps/boxstation.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1

	// Config actually from the JSON - should default to Box
	var/map_name = "Box Station"
	var/map_path = "map_files/BoxStation"
	var/map_file = "BoxStation.dmm"

	var/allow_custom_shuttles = TRUE
	var/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")

	var/minetype = "lavaland"

/proc/load_map_config(filename = "data/next_map.json", default_to_box, delete_after, error_if_missing = TRUE)
	var/datum/map_config/config = new
	if (default_to_box)
		return config
	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		return new /datum/map_config  // Fall back to Box
	if (delete_after)
		fdel(filename)
	return config

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]
	CHECK_EXISTS("map_file")
	map_file = json["map_file"]

	var/path = GetFullMapPath(json["map_path"], json["map_file"])
	if(!fexists(path))
		log_world("Map file ([path]) does not exist!")
		return

	if(islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config[shuttles] is not a list!")
		return

	var/json_minetype = json["minetype"]
	if (json_minetype)
		minetype = json_minetype

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPath(mp = map_path, mf = map_file)
	return "_maps/[mp]/[mf]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
