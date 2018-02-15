//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	var/config_filename = "_maps/boxstation.json"
	var/map_name = "Box Station"
	var/map_path = "map_files/BoxStation"
	var/map_file = "BoxStation.dmm"

	var/minetype = "lavaland"

	var/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_box",
		"emergency" = "emergency_box")

	//Order matters here.
	var/list/transition_config = list(CENTCOM = SELFLOOPING,
									MAIN_STATION = CROSSLINKED,
									EMPTY_AREA_1 = CROSSLINKED,
									EMPTY_AREA_2 = CROSSLINKED,
									MINING = SELFLOOPING,
									CITY_OF_COGS = SELFLOOPING,
									EMPTY_AREA_3 = CROSSLINKED,
									EMPTY_AREA_4 = CROSSLINKED,
									EMPTY_AREA_5 = CROSSLINKED,
									EMPTY_AREA_6 = CROSSLINKED,
									EMPTY_AREA_7 = CROSSLINKED,
									EMPTY_AREA_8 = CROSSLINKED)
	var/defaulted = TRUE    //if New failed

	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/allow_custom_shuttles = TRUE

/datum/map_config/New(filename = "data/next_map.json", default_to_box, delete_after, error_if_missing = TRUE)
	if(default_to_box)
		return
	LoadConfig(filename, error_if_missing)
	if(delete_after)
		fdel(filename)

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

	if(!ValidateJSON(json))
		log_world("map_config failed to validate for above reason: [filename]")
		return

	config_filename = filename

	map_name = json["map_name"]
	map_path = json["map_path"]
	map_file = json["map_file"]

	if(islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value

	minetype = json["minetype"] || minetype
	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

	var/jtcl = json["transition_config"]
	if(jtcl && jtcl != "default")
		transition_config.Cut()

		for(var/I in jtcl)
			transition_config[TransitionStringToEnum(I)] = TransitionStringToEnum(jtcl[I])

	defaulted = FALSE

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/ValidateJSON(list/json)
	CHECK_EXISTS("map_name")
	CHECK_EXISTS("map_path")
	CHECK_EXISTS("map_file")

	var/shuttles = json["shuttles"]
	if(shuttles && !islist(shuttles))
		log_world("json\[shuttles\] is not a list!")

	var/path = GetFullMapPath(json["map_path"], json["map_file"])
	if(!fexists(path))
		log_world("Map file ([path]) does not exist!")
		return

	var/tc = json["transition_config"]
	if(tc != null && tc != "default")
		if(!islist(tc))
			log_world("transition_config is not a list!")
			return

		for(var/I in tc)
			if(isnull(TransitionStringToEnum(I)))
				log_world("Invalid transition_config option: [I]!")
			if(isnull(TransitionStringToEnum(tc[I])))
				log_world("Invalid transition_config option: [I]!")

	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/TransitionStringToEnum(string)
	switch(string)
		if("CROSSLINKED")
			return CROSSLINKED
		if("SELFLOOPING")
			return SELFLOOPING
		if("UNAFFECTED")
			return UNAFFECTED
		if("MAIN_STATION")
			return MAIN_STATION
		if("CENTCOM")
			return CENTCOM
		if("CITY_OF_COGS")
			return CITY_OF_COGS
		if("MINING")
			return MINING
		if("EMPTY_AREA_1")
			return EMPTY_AREA_1
		if("EMPTY_AREA_2")
			return EMPTY_AREA_2
		if("EMPTY_AREA_3")
			return EMPTY_AREA_3
		if("EMPTY_AREA_4")
			return EMPTY_AREA_4
		if("EMPTY_AREA_5")
			return EMPTY_AREA_5
		if("EMPTY_AREA_6")
			return EMPTY_AREA_6
		if("EMPTY_AREA_7")
			return EMPTY_AREA_7
		if("EMPTY_AREA_8")
			return EMPTY_AREA_8

/datum/map_config/proc/GetFullMapPath(mp = map_path, mf = map_file)
	return "_maps/[mp]/[mf]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
