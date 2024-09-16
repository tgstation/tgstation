///Loads all engravings, and places a select amount in maintenance and the prison.
/datum/controller/subsystem/persistence/proc/load_wall_engravings()
	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(!fexists(json_file))
		return

	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < ENGRAVING_PERSISTENCE_VERSION)
		update_wall_engravings(json)

	saved_engravings = json["entries"]

	if(!saved_engravings.len)
		log_world("Failed to load engraved messages on map [SSmapping.config.map_name]")
		return

	var/list/viable_turfs = get_area_turfs(/area/station/maintenance, subtypes = TRUE) + get_area_turfs(/area/station/security/prison, subtypes = TRUE)
	var/list/turfs_to_pick_from = list()

	for(var/turf/T as anything in viable_turfs)
		if(!isclosedturf(T))
			continue
		turfs_to_pick_from += T

	var/successfully_loaded_engravings = 0

	for(var/iteration in 1 to min(rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS), saved_engravings.len))
		var/engraving = pick_n_take(saved_engravings)
		if(!islist(engraving))
			stack_trace("something's wrong with the engraving data! one of the saved engravings wasn't a list!")
			continue

		var/turf/closed/engraved_wall = pick(turfs_to_pick_from)

		if(HAS_TRAIT(engraved_wall, TRAIT_NOT_ENGRAVABLE))
			continue

		engraved_wall.AddComponent(/datum/component/engraved, engraving["story"], FALSE, engraving["story_value"])
		successfully_loaded_engravings++
		turfs_to_pick_from -= engraved_wall

	log_world("Loaded [successfully_loaded_engravings] engraved messages on map [SSmapping.config.map_name]")

///Saves all new engravings in the world.
/datum/controller/subsystem/persistence/proc/save_wall_engravings()
	var/list/saved_data = list()

	saved_data["version"] = ENGRAVING_PERSISTENCE_VERSION
	saved_data["entries"] = list()


	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			saved_data["entries"] = old_json["entries"]

	for(var/datum/component/engraved/engraving in wall_engravings)
		if(!engraving.persistent_save)
			continue
		var/area/engraved_area = get_area(engraving.parent)
		if(!(engraved_area.area_flags & PERSISTENT_ENGRAVINGS))
			continue
		saved_data["entries"] += engraving.save_persistent()

	fdel(json_file)

	WRITE_FILE(json_file, json_encode(saved_data))

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_wall_engravings(json)
	for(var/engraving_entry in json["entries"])
		continue //no versioning yet

	//Save it to the file
	var/json_file = file(ENGRAVING_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json

