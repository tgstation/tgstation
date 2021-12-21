#define FILE_RECENT_MAPS "data/RecentMaps.json"

#define KEEP_ROUNDS_MAP 3

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///instantiated wall engraving components
	var/list/wall_engravings = list()
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


/datum/controller/subsystem/persistence/Initialize()
	LoadPoly()
	load_wall_engravings()
	load_prisoner_tattoos()
	LoadTrophies()
	LoadRecentMaps()
	LoadPhotoPersistence()
	LoadRandomizedRecipes()
	load_custom_outfits()

	load_adventures()
	return ..()

/datum/controller/subsystem/persistence/proc/collect_data()
	save_wall_engravings()
	save_prisoner_tattoos()
	CollectTrophies()
	CollectMaps()
	SavePhotoPersistence() //THIS IS PERSISTENCE, NOT THE LOGGING PORTION.
	SaveRandomizedRecipes()
	SaveScars()
	save_custom_outfits()

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/poly/P in GLOB.alive_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/load_wall_engravings()
	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < ENGRAVING_PERSISTENCE_VERSION)
		update_wall_engravings(json)

	var/successfully_loaded_engravings = 0

	var/list/viable_turfs = get_area_turfs(/area/maintenance) + get_area_turfs(/area/security/prison)
	var/list/turfs_to_pick_from = list()

	for(var/turf/T as anything in viable_turfs)
		if(!isclosedturf(T))
			continue
		turfs_to_pick_from += T

	var/list/engraving_entries = json["entries"]

	if(engraving_entries.len)
		for(var/iteration in 1 to rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS))
			var/engraving = engraving_entries[rand(1, engraving_entries.len)] //This means repeats will happen for now, but its something I can live with. Just make more engravings!
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


/datum/controller/subsystem/persistence/proc/LoadTrophies()
	if(fexists("data/npc_saves/TrophyItems.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/TrophyItems.sav")
		var/saved_json
		S >> saved_json
		if(!saved_json)
			return
		saved_trophies = json_decode(saved_json)
		fdel("data/npc_saves/TrophyItems.sav")
	else
		var/json_file = file("data/npc_saves/TrophyItems.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		if(!json)
			return
		saved_trophies = json["data"]
	SetUpTrophies(saved_trophies.Copy())

/datum/controller/subsystem/persistence/proc/LoadRecentMaps()
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

/datum/controller/subsystem/persistence/proc/SetUpTrophies(list/trophy_items)
	for(var/A in GLOB.trophy_cases)
		var/obj/structure/displaycase/trophy/T = A
		if (T.showpiece)
			continue
		T.added_roundstart = TRUE

		var/trophy_data = pick_n_take(trophy_items)

		if(!islist(trophy_data))
			continue

		var/list/chosen_trophy = trophy_data

		if(!length(chosen_trophy)) //Malformed
			continue

		var/path = text2path(chosen_trophy["path"]) //If the item no longer exist, this returns null
		if(!path)
			continue

		T.showpiece = new /obj/item/showpiece_dummy(T, path)
		T.trophy_message = chosen_trophy["message"]
		T.placer_key = chosen_trophy["placer_key"]
		T.update_appearance()

/datum/controller/subsystem/persistence/proc/GetPhotoAlbums()
	var/album_path = file("data/photo_albums.json")
	if(fexists(album_path))
		return json_decode(file2text(album_path))

/datum/controller/subsystem/persistence/proc/GetPhotoFrames()
	var/frame_path = file("data/photo_frames.json")
	if(fexists(frame_path))
		return json_decode(file2text(frame_path))

/// Removes the identifier of a persitent photo frame from the json.
/datum/controller/subsystem/persistence/proc/RemovePhotoFrame(identifier)
	var/frame_path = file("data/photo_frames.json")
	if(!fexists(frame_path))
		return

	var/frame_json = json_decode(file2text(frame_path))
	frame_json -= identifier

	frame_json = json_encode(frame_json)
	fdel(frame_path)
	WRITE_FILE(frame_path, frame_json)

/datum/controller/subsystem/persistence/proc/LoadPhotoPersistence()
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

/datum/controller/subsystem/persistence/proc/SavePhotoPersistence()
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

/datum/controller/subsystem/persistence/proc/CollectTrophies()
	var/json_file = file("data/npc_saves/TrophyItems.json")
	var/list/file_data = list()
	file_data["data"] = remove_duplicate_trophies(saved_trophies)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

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

/datum/controller/subsystem/persistence/proc/SaveTrophy(obj/structure/displaycase/trophy/T)
	if(!T.added_roundstart && T.showpiece)
		var/list/data = list()
		data["path"] = T.showpiece.type
		data["message"] = T.trophy_message
		data["placer_key"] = T.placer_key
		saved_trophies += list(data)

/datum/controller/subsystem/persistence/proc/CollectMaps()
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

/datum/controller/subsystem/persistence/proc/LoadRandomizedRecipes()
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

/datum/controller/subsystem/persistence/proc/SaveRandomizedRecipes()
	var/json_file = file("data/RandomizedChemRecipes.json")
	var/list/file_data = list()

	//asert globchems done
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/R = get_chemical_reaction(randomized_type) //ew, would be nice to add some simple tracking
		if(R?.persistent)
			var/recipe_data = list()
			recipe_data["timestamp"] = R.created
			recipe_data["required_reagents"] = R.required_reagents
			recipe_data["required_catalysts"] = R.required_catalysts
			recipe_data["required_temp"] = R.required_temp
			recipe_data["is_cold_recipe"] = R.is_cold_recipe
			recipe_data["results"] = R.results
			recipe_data["required_container"] = "[R.required_container]"
			file_data["[R.type]"] = recipe_data

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/SaveScars()
	for(var/i in GLOB.joined_player_list)
		var/mob/living/carbon/human/ending_human = get_mob_by_ckey(i)
		if(!istype(ending_human) || !ending_human.mind?.original_character_slot_index || !ending_human.client || !ending_human.client.prefs || !ending_human.client.prefs.persistent_scars)
			continue

		var/mob/living/carbon/human/original_human = ending_human.mind.original_character.resolve()

		if(!original_human)
			continue

		if(original_human.stat == DEAD || !original_human.all_scars || original_human != ending_human)
			original_human.save_persistent_scars(TRUE)
		else
			original_human.save_persistent_scars()


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

/datum/controller/subsystem/persistence/proc/save_custom_outfits()
	var/file = file("data/custom_outfits.json")
	fdel(file)

	var/list/data = list()
	for(var/datum/outfit/outfit in GLOB.custom_outfits)
		data += list(outfit.get_json_data())

	WRITE_FILE(file, json_encode(data))
