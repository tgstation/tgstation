///Loads all statue engravings, and places a select amount in maintenance and the prison.
/datum/controller/subsystem/persistence/proc/load_statues()
	var/json_file = file(STATUE_ENGRAVING_SAVE_FILE)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < STATUE_ENGRAVING_PERSISTENCE_VERSION)
		update_statue_engravings(json)

	var/successfully_loaded_statue_engravings = 0

	// /obj/effect/spawner/random/decoration/statue

statues fixes:
- pixel offsets
- direction
- animation
- lighting


	var/list/engraving_entries = json["entries"]

	if(engraving_entries.len)
		for(var/iteration in 1 to rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS))
			var/engraving = pick_n_take(engraving_entries) //engraving_entries[rand(1, engraving_entries.len)] //This means repeats will happen for now, but its something I can live with. Just make more engravings!
			if(!islist(engraving))
				stack_trace("something's wrong with the engraving data! one of the saved engravings wasn't a list!")
				continue

			var/turf/closed/engraved_wall = pick(turfs_to_pick_from)

			if(HAS_TRAIT(engraved_wall, TRAIT_NOT_ENGRAVABLE))
				continue

			engraved_wall.AddComponent(/datum/component/engraved, engraving["story"], FALSE, engraving["story_value"])
			successfully_loaded_statue_engravings++
			turfs_to_pick_from -= engraved_wall

	log_world("Loaded [successfully_loaded_statue_engravings] engraved statues on map [SSmapping.config.map_name]")

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_statue_engravings(json)
	for(var/engraving_entry in json["entries"])
		continue //no versioning yet

	//Save it to the file
	var/json_file = file(STATUE_ENGRAVING_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json

///Saves our custom statue data to be used for later rounds
/datum/controller/subsystem/persistence/proc/save_statue(obj/structure/statue/custom/custom_statue)
	saved_data["entries"] += engraving.save_persistent()

///Saves statues if they successfully enter the hall of fame shuttle
/datum/controller/subsystem/persistence/proc/collect_statues()
	if(!EMERGENCY_ESCAPED_OR_ENDGAMED && !istype(SSshuttle.selected, /datum/map_template/shuttle/emergency/fame))
		return

	var/list/saved_data = list()

	saved_data["version"] = STATUE_ENGRAVING_PERSISTENCE_VERSION
	saved_data["entries"] = list()

	var/json_file = file(STATUE_ENGRAVING_SAVE_FILE)
	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			saved_data["entries"] = old_json["entries"]

	for(var/obj/structure/statue/custom/custom_statue in GLOB.custom_statues)
		if(!custom_statue.onCentCom())
			continue

		var/datum/component/engraved/engraving = custom_statue.GetComponent(/datum/component/engraved)

		// the statue needs to be engraved and not a persistent loaded one from a previous round
		if(engarving && !engraving.persistent_save)
			saved_data["entries"] += save_statue(custom_statue)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(saved_data))

