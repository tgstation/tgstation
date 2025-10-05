//This file is used to contain unique properties of every map, and how we wish to alter them on a per-map basis.
//Use JSON files that match the datum layout and you should be set from there.
//Right now, we default to MetaStation to ensure something does indeed load by default.
//  -san7890 (with regards to Cyberboss)

/datum/map_config
	// Metadata
	var/config_filename = "_maps/metastation.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/votable = FALSE

	///A URL linking to a place for people to send feedback about this map.
	var/feedback_link

	/// The URL given by config directing you to the webmap.
	var/mapping_url

	// Config actually from the JSON - should default to Meta
	var/map_name = "MetaStation"
	var/map_path = "map_files/MetaStation"
	var/map_file = "MetaStation.dmm"

	var/traits = null
	var/space_ruin_levels = DEFAULT_SPACE_RUIN_LEVELS
	var/space_empty_levels = DEFAULT_SPACE_EMPTY_LEVELS

	/// Boolean that tells us if this is a planetary station. (like IceBoxStation)
	var/planetary = FALSE
	/// How many z's to generate around a planetary station
	var/wilderness_levels = 0
	/// Directory to the wilderness area we can spawn in
	var/wilderness_directory
	/// Index of map names (inside wilderness_directory) with the amount to spawn. ("ice_planes" = 1) for one ice spawn
	var/list/maps_to_spawn = list()

	///The type of mining Z-level that should be loaded.
	var/minetype = MINETYPE_LAVALAND
	///If no minetype is set, this will be the blacklist file used
	var/blacklist_file

	var/allow_custom_shuttles = TRUE
	var/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_meta",
		"emergency" = "emergency_meta",
	)

	/// Dictionary of job sub-typepath to template changes dictionary
	var/job_changes = list()
	/// List of additional areas that count as a part of the library
	var/library_areas = list()
	/// Boolean - if TRUE, the "Up" and "Down" traits are automatically distributed to the map's z-levels. If FALSE; they're set via JSON.
	var/height_autosetup = TRUE

	/// Boolean - if TRUE, players spawn with grappling hooks in their bags
	var/give_players_hooks = FALSE

	/// List of unit tests that are skipped when running this map
	var/list/skipped_tests

	/// Boolean that tells SSmapping to load all away missions in the codebase.
	var/load_all_away_missions = FALSE

/**
 * Proc that simply loads the default map config, which should always be functional.
 */
/proc/load_default_map_config()
	return new /datum/map_config


/**
 * Proc handling the loading of map configs. Will return the default map config using [/proc/load_default_map_config] if the loading of said file fails for any reason whatsoever, so we always have a working map for the server to run.
 * Arguments:
 * * filename - Name of the config file for the map we want to load. The .json file extension is added during the proc, so do not specify filenames with the extension.
 * * directory - Name of the directory containing our .json - Must be in MAP_DIRECTORY_WHITELIST. We default this to MAP_DIRECTORY_MAPS as it will likely be the most common usecase. If no filename is set, we ignore this.
 * * error_if_missing - Bool that says whether failing to load the config for the map will be logged in log_world or not as it's passed to LoadConfig().
 *
 * Returns the config for the map to load.
 */
/proc/load_map_config(filename = null, directory = null, error_if_missing = TRUE)
	var/datum/map_config/configuring_map = load_default_map_config()

	if(filename) // If none is specified, then go to look for next_map.json, for map rotation purposes.

		//Default to MAP_DIRECTORY_MAPS if no directory is passed
		if(directory)
			if(!(directory in MAP_DIRECTORY_WHITELIST))
				log_world("map directory not in whitelist: [directory] for map [filename]")
				return configuring_map
		else
			directory = MAP_DIRECTORY_MAPS

		filename = "[directory]/[filename].json"
	else
		filename = PATH_TO_NEXT_MAP_JSON


	if (!configuring_map.LoadConfig(filename, error_if_missing))
		qdel(configuring_map)
		return load_default_map_config()
	return configuring_map


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

	if(!json["version"])
		log_world("map_config missing version!")
		return

	if(json["version"] != MAP_CURRENT_VERSION)
		log_world("map_config has invalid version [json["version"]]!")
		return

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	map_file = json["map_file"]
	// "map_file": "MetaStation.dmm"
	if (istext(map_file))
		if (!fexists("_maps/[map_path]/[map_file]"))
			log_world("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("_maps/[map_path]/[file]"))
				log_world("Map file ([map_path]/[file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if (islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAIT_STATION in level))
				level[ZTRAIT_STATION] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_ruin_levels"]
	if (isnum(temp))
		space_ruin_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_ruin_levels is not a number!")
		return

	temp = json["space_empty_levels"]
	if (isnum(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	temp = json["wilderness_levels"]
	if (isnum(temp))
		wilderness_levels = temp
	else if (!isnull(temp))
		log_world("map_config wilderness_levels is not a number!")
		return

	if ("minetype" in json)
		minetype = json["minetype"]

	if ("planetary" in json)
		planetary = json["planetary"]

	if ("blacklist_file" in json)
		blacklist_file = json["blacklist_file"]

	if ("load_all_away_missions" in json)
		load_all_away_missions = json["load_all_away_missions"]

	if ("give_players_hooks" in json)
		give_players_hooks = json["give_players_hooks"]

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	if ("job_changes" in json)
		if(!islist(json["job_changes"]))
			log_world("map_config \"job_changes\" field is missing or invalid!")
			return
		job_changes = json["job_changes"]

	if("library_areas" in json)
		if(!islist(json["library_areas"]))
			log_world("map_config \"library_areas\" field is missing or invalid!")
			return
		for(var/path_as_text in json["library_areas"])
			var/path = text2path(path_as_text)
			if(!ispath(path, /area))
				stack_trace("Invalid path in mapping config for additional library areas: \[[path_as_text]\]")
				continue
			library_areas += path

	if ("height_autosetup" in json)
		height_autosetup = json["height_autosetup"]

	var/list/wilderness = json["wilderness"]
	// If we got wilderness levels, fetch them from the config
	if (islist(wilderness))
		wilderness_directory = wilderness["directory"]
		wilderness.Remove("directory")

		// Just pick and take based on weight
		for(var/i in 1 to wilderness_levels)
			maps_to_spawn += pick_weight_take(wilderness)
		shuffle(maps_to_spawn)

#ifdef UNIT_TESTS
	// Check for unit tests to skip, no reason to check these if we're not running tests
	for(var/path_as_text in json["ignored_unit_tests"])
		var/path_real = text2path(path_as_text)
		if(!ispath(path_real, /datum/unit_test))
			stack_trace("Invalid path in mapping config for ignored unit tests: \[[path_as_text]\]")
			continue
		LAZYADD(skipped_tests, path_real)
#endif

	defaulted = FALSE
	return json
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("_maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "_maps/[map_path]/[file]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == PATH_TO_NEXT_MAP_JSON || fcopy(config_filename, PATH_TO_NEXT_MAP_JSON)
