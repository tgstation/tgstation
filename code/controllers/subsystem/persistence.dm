#define FILE_RECENT_MAPS "data/RecentMaps.json"

#define KEEP_ROUNDS_MAP 3

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///instantiated wall engraving components
	var/list/wall_engravings = list()
	///all saved persistent engravings loaded from JSON
	var/list/saved_engravings = list()
	///tattoo stories that we're saving.
	var/list/prison_tattoos_to_save = list()
	///tattoo stories that have been selected for this round.
	var/list/prison_tattoos_to_use = list()
	var/list/saved_messages = list()
	var/list/saved_modes = list(1,2,3)
	var/list/saved_maps = list()
	var/list/blocked_maps = list()
	var/list/saved_trophies = list()
	var/list/picture_logging_information = list()
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums
	var/rounds_since_engine_exploded = 0
	var/delam_highscore = 0
	var/tram_hits_this_round = 0
	var/tram_hits_last_round = 0

/datum/controller/subsystem/persistence/Initialize()
	load_poly()
	load_wall_engravings()
	load_prisoner_tattoos()
	load_trophies()
	load_recent_maps()
	load_photo_persistence()
	load_randomized_recipes()
	load_custom_outfits()
	load_delamination_counter()
	load_tram_counter()
	load_adventures()
	return SS_INIT_SUCCESS

///Collects all data to persist.
/datum/controller/subsystem/persistence/proc/collect_data()
	save_wall_engravings()
	save_prisoner_tattoos()
	collect_trophies()
	collect_maps()
	save_photo_persistence() //THIS IS PERSISTENCE, NOT THE LOGGING PORTION.
	save_randomized_recipes()
	save_scars()
	save_custom_outfits()
	save_delamination_counter()
	if(SStramprocess.can_fire)
		save_tram_counter()

///Loads up Poly's speech buffer.
/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/simple_animal/parrot/poly/P in GLOB.alive_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

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

	for(var/iteration in 1 to rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS))
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

///trophy data datum, for admin manipulation
/datum/trophy_data
	///path of the item the trophy will try to mimic, null if path_string is invalid
	var/path
	///the message that appears under the item
	var/message
	///the key of the one who placed the item in the trophy case
	var/placer_key

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

/// Loads up the amount of times maps appeared to alter their appearance in voting and rotation.
/datum/controller/subsystem/persistence/proc/load_recent_maps()
	var/map_sav = FILE_RECENT_MAPS
	if(!fexists(FILE_RECENT_MAPS))
		return
	var/list/json = json_decode(file2text(map_sav))
	if(!json)
		return
	saved_maps = json["data"]

	//Convert the mapping data to a shared blocking list, saves us doing this in several places later.
	for(var/map in config.maplist)
		var/datum/map_config/VM = config.maplist[map]
		var/run = 0
		if(VM.map_name == SSmapping.config.map_name)
			run++
		for(var/name in SSpersistence.saved_maps)
			if(VM.map_name == name)
				run++
		if(run >= 2) //If run twice in the last KEEP_ROUNDS_MAP + 1 (including current) rounds, disable map for voting and rotation.
			blocked_maps += VM.map_name

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

///Loads up the photo album source file.
/datum/controller/subsystem/persistence/proc/get_photo_albums()
	var/album_path = file("data/photo_albums.json")
	if(fexists(album_path))
		return json_decode(file2text(album_path))

///Loads up the photo frames source file.
/datum/controller/subsystem/persistence/proc/get_photo_frames()
	var/frame_path = file("data/photo_frames.json")
	if(fexists(frame_path))
		return json_decode(file2text(frame_path))

/// Removes the identifier of a persistent photo frame from the json.
/datum/controller/subsystem/persistence/proc/remove_photo_frames(identifier)
	var/frame_path = file("data/photo_frames.json")
	if(!fexists(frame_path))
		return

	var/frame_json = json_decode(file2text(frame_path))
	frame_json -= identifier

	frame_json = json_encode(frame_json)
	fdel(frame_path)
	WRITE_FILE(frame_path, frame_json)

///Loads photo albums, and populates them; also loads and applies frames to picture frames.
/datum/controller/subsystem/persistence/proc/load_photo_persistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")
	if(fexists(album_path))
		var/list/json = json_decode(file2text(album_path))
		if(json.len)
			for(var/i in photo_albums)
				var/obj/item/storage/photo_album/A = i
				if(!A.persistence_id)
					continue
				if(json[A.persistence_id])
					A.populate_from_id_list(json[A.persistence_id])

	if(fexists(frame_path))
		var/list/json = json_decode(file2text(frame_path))
		if(json.len)
			for(var/i in photo_frames)
				var/obj/structure/sign/picture_frame/PF = i
				if(!PF.persistence_id)
					continue
				if(json[PF.persistence_id])
					PF.load_from_id(json[PF.persistence_id])

///Saves the contents of photo albums and the picture frames.
/datum/controller/subsystem/persistence/proc/save_photo_persistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")

	var/list/frame_json = list()
	var/list/album_json = list()

	if(fexists(album_path))
		album_json = json_decode(file2text(album_path))
		fdel(album_path)

	for(var/i in photo_albums)
		var/obj/item/storage/photo_album/A = i
		if(!istype(A) || !A.persistence_id)
			continue
		var/list/L = A.get_picture_id_list()
		album_json[A.persistence_id] = L

	album_json = json_encode(album_json)

	WRITE_FILE(album_path, album_json)

	if(fexists(frame_path))
		frame_json = json_decode(file2text(frame_path))
		fdel(frame_path)

	for(var/i in photo_frames)
		var/obj/structure/sign/picture_frame/F = i
		if(!istype(F) || !F.persistence_id)
			continue
		frame_json[F.persistence_id] = F.get_photo_id()

	frame_json = json_encode(frame_json)

	WRITE_FILE(frame_path, frame_json)

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

///Updates the list of the most recent maps.
/datum/controller/subsystem/persistence/proc/collect_maps()
	if(length(saved_maps) > KEEP_ROUNDS_MAP) //Get rid of extras from old configs.
		saved_maps.Cut(KEEP_ROUNDS_MAP+1)
	var/mapstosave = min(length(saved_maps)+1, KEEP_ROUNDS_MAP)
	if(length(saved_maps) < mapstosave) //Add extras if too short, one per round.
		saved_maps += mapstosave
	for(var/i = mapstosave; i > 1; i--)
		saved_maps[i] = saved_maps[i-1]
	saved_maps[1] = SSmapping.config.map_name
	var/json_file = file(FILE_RECENT_MAPS)
	var/list/file_data = list()
	file_data["data"] = saved_maps
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///Loads all randomized recipes.
/datum/controller/subsystem/persistence/proc/load_randomized_recipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/json
	if(fexists(json_file))
		json = json_decode(file2text(json_file))

	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = new randomized_type
		var/loaded = FALSE
		if(R.persistent && json)
			var/list/recipe_data = json["[R.type]"]
			if(recipe_data)
				if(R.LoadOldRecipe(recipe_data) && (daysSince(R.created) <= R.persistence_period))
					loaded = TRUE
		if(!loaded) //We do not have information for whatever reason, just generate new one
			if(R.persistent)
				log_game("Resetting persistent [randomized_type] random recipe.")
			R.GenerateRecipe()

		if(!R.HasConflicts()) //Might want to try again if conflicts happened in the future.
			add_chemical_reaction(R)
		else
			log_game("Randomized recipe [randomized_type] resulted in conflicting recipes.")

///Saves all randomized recipes.
/datum/controller/subsystem/persistence/proc/save_randomized_recipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/list/file_data = list()

	//asert globchems done
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = get_chemical_reaction(randomized_type) //ew, would be nice to add some simple tracking
		if(R?.persistent)
			var/list/recipe_data = R.SaveOldRecipe()
			file_data["[R.type]"] = recipe_data

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///Saves all scars for everyone's original characters
/datum/controller/subsystem/persistence/proc/save_scars()
	for(var/i in GLOB.joined_player_list)
		var/mob/living/carbon/human/ending_human = get_mob_by_ckey(i)
		if(!istype(ending_human) || !ending_human.mind?.original_character_slot_index || !ending_human.client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
			continue

		var/mob/living/carbon/human/original_human = ending_human.mind.original_character.resolve()

		if(!original_human)
			continue

		if(original_human.stat == DEAD || !original_human.all_scars || original_human != ending_human)
			original_human.save_persistent_scars(TRUE)
		else
			original_human.save_persistent_scars()

///Loads the custom outfits of every admin.
/datum/controller/subsystem/persistence/proc/load_custom_outfits()
	var/file = file("data/custom_outfits.json")
	if(!fexists(file))
		return
	var/outfits_json = file2text(file)
	var/list/outfits = json_decode(outfits_json)
	if(!islist(outfits))
		return

	for(var/outfit_data in outfits)
		if(!islist(outfit_data))
			continue

		var/outfittype = text2path(outfit_data["outfit_type"])
		if(!ispath(outfittype, /datum/outfit))
			continue
		var/datum/outfit/outfit = new outfittype
		if(!outfit.load_from(outfit_data))
			continue
		GLOB.custom_outfits += outfit

///Saves each admin's custom outfit list
/datum/controller/subsystem/persistence/proc/save_custom_outfits()
	var/file = file("data/custom_outfits.json")
	fdel(file)

	var/list/data = list()
	for(var/datum/outfit/outfit in GLOB.custom_outfits)
		data += list(outfit.get_json_data())

	WRITE_FILE(file, json_encode(data))

/// Location where we save the information about how many rounds it has been since the engine blew up/tram hits
#define DELAMINATION_COUNT_FILEPATH "data/rounds_since_delamination.txt"
#define DELAMINATION_HIGHSCORE_FILEPATH "data/delamination_highscore.txt"
#define TRAM_COUNT_FILEPATH "data/tram_hits_last_round.txt"

/datum/controller/subsystem/persistence/proc/load_delamination_counter()
	if (!fexists(DELAMINATION_COUNT_FILEPATH))
		return
	rounds_since_engine_exploded = text2num(file2text(DELAMINATION_COUNT_FILEPATH))
	if (fexists(DELAMINATION_HIGHSCORE_FILEPATH))
		delam_highscore = text2num(file2text(DELAMINATION_HIGHSCORE_FILEPATH))
	for (var/obj/machinery/incident_display/sign as anything in GLOB.map_delamination_counters)
		sign.update_delam_count(rounds_since_engine_exploded, delam_highscore)

/datum/controller/subsystem/persistence/proc/save_delamination_counter()
	rustg_file_write("[rounds_since_engine_exploded + 1]", DELAMINATION_COUNT_FILEPATH)
	if((rounds_since_engine_exploded + 1) > delam_highscore)
		rustg_file_write("[rounds_since_engine_exploded + 1]", DELAMINATION_HIGHSCORE_FILEPATH)

/datum/controller/subsystem/persistence/proc/load_tram_counter()
	if(!fexists(TRAM_COUNT_FILEPATH))
		return
	tram_hits_last_round = text2num(file2text(TRAM_COUNT_FILEPATH))

/datum/controller/subsystem/persistence/proc/save_tram_counter()
		rustg_file_write("[tram_hits_this_round]", TRAM_COUNT_FILEPATH)

#undef DELAMINATION_COUNT_FILEPATH
#undef DELAMINATION_HIGHSCORE_FILEPATH
#undef TRAM_COUNT_FILEPATH
#undef FILE_RECENT_MAPS
#undef KEEP_ROUNDS_MAP
