#define FILE_RECENT_MAPS "data/RecentMaps.json"
#define KEEP_ROUNDS_MAP 3
#define INFINITE_AUTOSAVES -1
#define SAVE_COMPLETION_MARKER "save_complete.txt"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	flags = SS_BACKGROUND
	wait = INFINITY
	runlevels = RUNLEVEL_GAME

	/// This is used to skip the 1st autosave that is automatically done vis the subsystems fire() at roundstart
	var/was_first_roundstart_autosave_skipped = FALSE
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

	/// A json_database linking to data/photo_frames.json.
	/// Schema is persistence_id => array of photo names.
	var/datum/json_database/photo_frames_database

	/// A lazy list of every picture frame that is going to be loaded with persistent photos.
	/// Will be null'd once the persistence system initializes, and never read from again.
	var/list/obj/structure/sign/picture_frame/queued_photo_frames

	/// A json_database linking to data/photo_albums.json.
	/// Schema is persistence_id => array of photo names.
	var/datum/json_database/photo_albums_database

	/// A lazy list of every photo album that is going to be loaded with persistent photos.
	/// Will be null'd once the persistence system initializes, and never read from again.
	var/list/obj/item/storage/photo_album/queued_photo_albums

	/// A json_database to data/piggy banks.json
	/// Schema is persistence_id => array of coins, space cash and holochips.
	var/datum/json_database/piggy_banks_database
	/// List of persistene ids which piggy banks.
	var/list/queued_broken_piggy_ids

	/// json database linking to data/trophy_fishes.json, for persistent trophy fish mount.
	var/datum/json_database/trophy_fishes_database

	var/rounds_since_engine_exploded = 0
	var/delam_highscore = 0
	var/tram_hits_this_round = 0
	var/tram_hits_last_round = 0

	/// A json database to data/message_bottles.json
	var/datum/json_database/message_bottles_database
	/// An index used to create unique ids for the message bottles database
	var/message_bottles_index = 0
	/**
	 * A list of non-maploaded photos or papers that met the 0.2% chance to be saved in the message bottles database
	 * because I don't want the database to feel empty unless there's someone constantly throwing bottles in the
	 * sea or beach/ocean fishing portals.
	 */
	var/list/queued_message_bottles

	/// A list of map config jsons used by persistence organized by z-level traits
	var/list/map_configs_cache
	/// Tracking variables for save metrics
	var/list/current_save_metrics = list()
	/// Current z-level being saved
	var/current_save_z_level = 0
	/// Current x coordinate being processed
	var/current_save_x = 0
	/// Current y coordinate being processed
	var/current_save_y = 0
	/// Whether a save operation is currently in progress
	var/save_in_progress = FALSE
	/// Areas that have been counted
	var/list/counted_areas = list()

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

	if(CONFIG_GET(number/persistent_autosave_period) > 0 && CONFIG_GET(flag/persistent_save_enabled))
		wait = CONFIG_GET(number/persistent_autosave_period) HOURS

	return SS_INIT_SUCCESS

/datum/controller/subsystem/persistence/fire(resumed = FALSE)
	if(!was_first_roundstart_autosave_skipped) // prevents pointless autosave at the start of the game
		was_first_roundstart_autosave_skipped = TRUE
		return

	save_world()

/// Saves map z-levels in the world based on PERSISTENT_SAVE_ENABLED config options in config/persistence.txt
/datum/controller/subsystem/persistence/proc/save_world(list/z_levels, silent=FALSE)
	log_world("World map save initiated at [time_stamp()]")
	if(!silent)
		to_chat(world, span_boldannounce("World map save initiated at [time_stamp()]"))

	save_persistent_maps(z_levels, silent)
	prune_old_autosaves()

///Collects all data to persist.
/datum/controller/subsystem/persistence/proc/collect_data()
	save_wall_engravings()
	save_prisoner_tattoos()
	collect_trophies()
	collect_maps()
	save_randomized_recipes()
	save_scars()
	save_custom_outfits()
	save_delamination_counter()
	save_queued_message_bottles()
	if(SStransport.can_fire)
		for(var/datum/transport_controller/linear/tram/transport as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
			save_tram_history(transport.specific_transport_id)
		save_tram_counter()


///Loads up Poly's speech buffer.
/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/basic/parrot/poly/bird in GLOB.alive_mob_list)
		var/list/list_to_read = bird.get_static_list_of_phrases()
		twitterize(list_to_read, "polytalk")
		break //Who's been duping the bird?!

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
		if(VM.map_name == SSmapping.current_map.map_name)
			run++
		for(var/name in SSpersistence.saved_maps)
			if(VM.map_name == name)
				run++
		if(run >= 2) //If run twice in the last KEEP_ROUNDS_MAP + 1 (including current) rounds, disable map for voting and rotation.
			blocked_maps += VM.map_name

///Updates the list of the most recent maps.
/datum/controller/subsystem/persistence/proc/collect_maps()
	if(length(saved_maps) > KEEP_ROUNDS_MAP) //Get rid of extras from old configs.
		saved_maps.Cut(KEEP_ROUNDS_MAP+1)
	var/mapstosave = min(length(saved_maps)+1, KEEP_ROUNDS_MAP)
	if(length(saved_maps) < mapstosave) //Add extras if too short, one per round.
		saved_maps += mapstosave
	for(var/i = mapstosave; i > 1; i--)
		saved_maps[i] = saved_maps[i-1]
	saved_maps[1] = SSmapping.current_map.map_name
	var/json_file = file(FILE_RECENT_MAPS)
	var/list/file_data = list()
	file_data["data"] = saved_maps
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

///Returns the path to persistence maps directory based on current timestamp format via YYYY-MM-DD_UTC_hh.mm.ss
/datum/controller/subsystem/persistence/proc/get_current_persistence_map_directory()
	var/realtime = world.realtime
	var/timestamp_utc  = time2text(realtime, "YYYY-MM-DD_UTC_hh.mm.ss", TIMEZONE_UTC)
	var/map_directory = MAP_PERSISTENT_DIRECTORY + timestamp_utc
	return map_directory

/datum/controller/subsystem/persistence/proc/is_save_valid(save_directory_name)
	var/full_path = MAP_PERSISTENT_DIRECTORY + save_directory_name
	var/completion_marker_path = "[full_path]/[SAVE_COMPLETION_MARKER]"

	if(!fexists(completion_marker_path))
		log_mapping("Save [save_directory_name] is incomplete - missing completion marker")
		return FALSE

	var/list/save_files = flist(full_path)
	if(save_files.len <= 1)
		log_mapping("Save [save_directory_name] appears empty except for completion marker")
		return FALSE

	return TRUE

///Deletes empty save directories and removes the oldest saves if the total count exceeds the max autosaves allowed in config
/datum/controller/subsystem/persistence/proc/prune_old_autosaves()
	if(!CONFIG_GET(flag/persistent_save_enabled))
		return

	// First, remove any corrupted/incomplete saves
	var/list/all_saves_raw = flist(MAP_PERSISTENT_DIRECTORY)
	for(var/save_directory in all_saves_raw)
		var/full_path = MAP_PERSISTENT_DIRECTORY + save_directory

		if(!flist(full_path).len)
			log_mapping("Deleted empty autosave: [full_path]")
			log_admin("Deleted empty autosave: [full_path]")
			fdel(full_path)
			continue

		if(!is_save_valid(save_directory))
			log_mapping("Deleted corrupted autosave: [full_path]")
			log_admin("Deleted corrupted autosave: [full_path]")
			fdel(full_path)

	if(CONFIG_GET(number/persistent_max_autosaves) == INFINITE_AUTOSAVES)
		return

	// organize by oldest saves first
	var/list/all_saves = get_all_saves(GLOBAL_PROC_REF(cmp_text_asc))
	if(!all_saves.len)
		return // no saves exist yet

	var/total_saves = all_saves.len
	var/saves_to_delete = total_saves - CONFIG_GET(number/persistent_max_autosaves)
	if(saves_to_delete <= 0)
		return

	for(var/i in 1 to saves_to_delete)
		var/oldest_autosave_full_path = MAP_PERSISTENT_DIRECTORY + all_saves[i]
		log_mapping("Deleted oldest autosave: [oldest_autosave_full_path]")
		log_admin("Deleted oldest autosave: [oldest_autosave_full_path]")
		fdel(oldest_autosave_full_path)

/datum/controller/subsystem/persistence/proc/get_last_save()
	// organize by newest saves first
	var/list/all_saves = get_all_saves(GLOBAL_PROC_REF(cmp_text_dsc))
	if(!all_saves.len)
		return null // no saves exist yet

	for(var/save_directory in all_saves)
		if(is_save_valid(save_directory))
			log_mapping("Using save: [save_directory]")
			return save_directory
		else
			log_mapping("Skipping corrupted/incomplete save: [save_directory]")

	log_mapping("ERROR: No valid saves found!")
	return null

/// Based on the last recent save, get a list of all z levels as numbers which have the specific trait
/// Will return null if no traits match or a save file doesn't exist yet
/datum/controller/subsystem/persistence/proc/cache_z_levels_map_configs()
	var/last_save_name = get_last_save()
	if(!last_save_name)
		log_world("WARNING: No valid persistence saves found")
		return null // no valid saves exist

	var/last_save = MAP_PERSISTENT_DIRECTORY + last_save_name

	var/list/matching_z_levels = list()
	var/list/last_save_files = flist(last_save)

	// Filter out the completion marker file
	last_save_files -= SAVE_COMPLETION_MARKER

	// prune the map .dmm files from our list since we only need JSONs
	for(var/dmm_file in last_save_files)
		if(copytext("[dmm_file]", -4) == ".dmm")
			last_save_files.Remove(dmm_file)

	// make sure only json files exist in this list because we have to sort them a special way
	for(var/file in last_save_files)
		if(copytext("[file]", -5) != ".json")
			CRASH("[file] in [last_save] directory is neither a .json or .dmm file")

	sortTim(last_save_files, GLOBAL_PROC_REF(cmp_persistent_saves_asc))
	last_save = copytext(last_save, 1, -1) // drop the "/" from the directory

	var/list/persistent_save_z_levels = CONFIG_GET(keyed_list/persistent_save_z_levels)

	for(var/json_file in last_save_files)
		// need to reformat the file name and directory to work with load_map_config()
		json_file = copytext(json_file, 1, -5) // drop the ".json" from file name
		var/datum/map_config/map_config = load_map_config(json_file, last_save, persistence_save = TRUE)

		// for persistent autosaves, the name is always a number which indicates the z-level
		var/current_z = map_config.map_name
		if(!islist(map_config.traits))
			CRASH("Missing list of traits in autosave json for [last_save]/[current_z].json")

		// for multi-z maps if a trait is found on ANY z-levels, the entire map is considered to have that trait
		for(var/level in map_config.traits)
			if(persistent_save_z_levels[ZTRAIT_CENTCOM] && (ZTRAIT_CENTCOM in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_CENTCOM])
				matching_z_levels[ZTRAIT_CENTCOM] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_STATION] && (ZTRAIT_STATION in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_STATION])
				matching_z_levels[ZTRAIT_STATION] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_MINING] && (ZTRAIT_MINING in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_MINING])
				matching_z_levels[ZTRAIT_MINING] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_SPACE_RUINS] && (ZTRAIT_SPACE_RUINS in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_SPACE_RUINS])
				matching_z_levels[ZTRAIT_SPACE_RUINS] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_SPACE_EMPTY] && (ZTRAIT_SPACE_EMPTY in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_SPACE_EMPTY])
				matching_z_levels[ZTRAIT_SPACE_EMPTY] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_ICE_RUINS] && (ZTRAIT_ICE_RUINS in level))
				LAZYINITLIST(matching_z_levels[ZTRAIT_ICE_RUINS])
				matching_z_levels[ZTRAIT_ICE_RUINS] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_RESERVED] && (ZTRAIT_RESERVED in level)) // for shuttles in transit (hyperspace)
				LAZYINITLIST(matching_z_levels[ZTRAIT_RESERVED])
				matching_z_levels[ZTRAIT_RESERVED] |= map_config
			else if(persistent_save_z_levels[ZTRAIT_AWAY] && (ZTRAIT_AWAY in level)) // gateway away missions
				LAZYINITLIST(matching_z_levels[ZTRAIT_AWAY])
				matching_z_levels[ZTRAIT_AWAY] |= map_config

	if(!matching_z_levels.len)
		return null

	matching_z_levels[PERSISTENT_LOADED_Z_LEVELS] = list()
	map_configs_cache = matching_z_levels
	return map_configs_cache

/*
 * Helper proc to get all saves that returns a list of paths relative to MAP_PERSISTENT_DIRECTORY
 * This will also prune any empty save directories by deleting them automatically
 * Args:
 * * sorting_method: This determines the sorting method and must be either OLDEST or NEWEST
 */
/datum/controller/subsystem/persistence/proc/get_all_saves(sorting_method)
	var/list/all_saves = flist(MAP_PERSISTENT_DIRECTORY)
	var/list/valid_saves = list()

	// Prune any empty save directories
	for(var/path in all_saves)
		if(is_save_valid(path))
			valid_saves += path

	sortTim(all_saves, sorting_method)
	return all_saves

/datum/controller/subsystem/persistence/proc/get_save_flags()
	var/flags = NONE

	var/list/persistent_save_flags = CONFIG_GET(keyed_list/persistent_save_flags)

	if(persistent_save_flags["objects"])
		flags |= SAVE_OBJECTS
	if(persistent_save_flags["objects_variables"])
		flags |= SAVE_OBJECTS_VARIABLES
	if(persistent_save_flags["objects_properties"])
		flags |= SAVE_OBJECTS_PROPERTIES

	if(persistent_save_flags["mobs"])
		flags |= SAVE_MOBS

	if(persistent_save_flags["turfs"])
		flags |= SAVE_TURFS
	if(persistent_save_flags["turfs_atmos"])
		flags |= SAVE_TURFS_ATMOS
	if(persistent_save_flags["turfs_space"])
		flags |= SAVE_TURFS_SPACE

	if(persistent_save_flags["areas"])
		flags |= SAVE_AREAS
	if(persistent_save_flags["areas_default_shuttles"])
		flags |= SAVE_AREAS_DEFAULT_SHUTTLES
	if(persistent_save_flags["areas_custom_shuttles"])
		flags |= SAVE_AREAS_CUSTOM_SHUTTLES

	return flags

/datum/controller/subsystem/persistence/proc/save_persistent_maps(list/z_levels, silent=FALSE)
	save_in_progress = TRUE
	current_save_metrics = list()
	counted_areas = list()

	GLOB.TGM_objs = 0
	GLOB.TGM_mobs = 0
	GLOB.TGM_total_objs = 0
	GLOB.TGM_total_mobs = 0
	GLOB.TGM_total_turfs = 0
	GLOB.TGM_total_areas = 0

	var/map_save_directory = get_current_persistence_map_directory()
	var/save_flags = get_save_flags()
	var/overall_save_start = REALTIMEOFDAY
	var/list/persistent_save_z_levels = CONFIG_GET(keyed_list/persistent_save_z_levels)

	for(var/z in 1 to world.maxz)
		var/list/level_traits = list()
		var/datum/space_level/level_to_check = SSmapping.z_list[z]
		var/list/z_traits = level_to_check.traits
		if(level_to_check.xi || level_to_check.yi)
			z_traits["xi"] = level_to_check.xi
			z_traits["yi"] = level_to_check.yi
		level_traits += list(z_traits)

		if(z_levels) // Skip saving z-levels based on num
			if(!z_levels[num2text(z)])
				continue
		else // Skip saving certain z-levels based on config settings
			if(!persistent_save_z_levels[ZTRAIT_CENTCOM] && is_centcom_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_STATION] && is_station_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_SPACE_EMPTY] && is_space_empty_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_SPACE_RUINS] && is_space_ruins_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_ICE_RUINS] && is_ice_ruins_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_MINING] && is_mining_level(z))
				continue
			else if(!persistent_save_z_levels[ZTRAIT_RESERVED] && is_reserved_level(z)) // for shuttles in transit (hyperspace)
				continue
			else if(!persistent_save_z_levels[ZTRAIT_AWAY] && is_away_level(z)) // gateway away missions
				continue

		var/bottom_z = z
		var/top_z = z
		if(is_multi_z_level(z))
			if(!SSmapping.level_trait(z, ZTRAIT_UP) || SSmapping.level_trait(z, ZTRAIT_DOWN))
				continue // skip all the other z levels if they aren't a bottom

			for(var/above_z in (bottom_z + 1) to world.maxz)
				var/datum/space_level/above_level_to_check = SSmapping.z_list[above_z]
				var/list/above_z_traits = above_level_to_check.traits
				if(above_level_to_check.xi || above_level_to_check.yi)
					above_z_traits["xi"] = above_level_to_check.xi
					above_z_traits["yi"] = above_level_to_check.yi
				level_traits += list(above_z_traits)

				if(!SSmapping.level_trait(above_z, ZTRAIT_UP) && SSmapping.level_trait(above_z, ZTRAIT_DOWN))
					top_z = above_z
					break

		// Update progress tracking for this z-level
		current_save_z_level = z
		current_save_x = 0
		current_save_y = 0
		var/z_objs_start = GLOB.TGM_total_objs
		var/z_mobs_start = GLOB.TGM_total_mobs
		var/z_turfs_start = GLOB.TGM_total_turfs
		var/z_areas_start = GLOB.TGM_total_areas

		var/z_save_time_start = REALTIMEOFDAY
		var/map = write_map(1, 1, bottom_z, world.maxx, world.maxy, top_z, save_flags)
		var/file_path = "[map_save_directory]/[z].dmm"
		rustg_file_write(map, file_path)
		var/map_path = copytext(map_save_directory, 7) // drop the "_maps/" from directory
		var/json_data = list(
			"version" = MAP_CURRENT_VERSION,
			"map_name" = level_to_check.name || CUSTOM_MAP_PATH,
			"map_path" = map_path,
			"map_file" = "[z].dmm",
			"traits" = level_traits,
			"minetype" = MINETYPE_NONE,
		)

		// saving station z-levels but not mining, we need to make sure minetype is included
		if(is_station_level(z) && !persistent_save_z_levels[ZTRAIT_MINING])
			json_data["minetype"] = SSmapping.current_map.minetype

		// consult is_on_a_planet() proc to see how planetary is determined
		// on mining levels, planetary is always TRUE and doesnt need to be set
		// on station levels, planetary is set via map_config (ie. Ice)
		if(is_station_level(z) && SSmapping.is_planetary())
			json_data["planetary"] = TRUE

		rustg_file_write(json_encode(json_data, JSON_PRETTY_PRINT), "[map_save_directory]/[z].json")

		var/z_save_time_end = (REALTIMEOFDAY - z_save_time_start) / 10
		current_save_metrics += list(list(
			"z-level" = bottom_z,
			"multi z-levels" = top_z - bottom_z,
			"save_time_seconds" = z_save_time_end,
			"mobs_saved" = GLOB.TGM_total_mobs - z_mobs_start,
			"objs_saved" = GLOB.TGM_total_objs - z_objs_start,
			"turfs_saved" = GLOB.TGM_total_turfs - z_turfs_start,
			"areas_saved" = GLOB.TGM_total_areas - z_areas_start,
		))

	var/overall_save_time_end = (REALTIMEOFDAY - overall_save_start) / 10
	var/completion_data = list(
		"save_completed" = TRUE,
		"timestamp" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"),
		"total_save_time_seconds" = overall_save_time_end,
		"z_level_metrics" = current_save_metrics
	)
	var/completion_marker_path = "[map_save_directory]/[SAVE_COMPLETION_MARKER]"
	rustg_file_write(json_encode(completion_data, JSON_PRETTY_PRINT), completion_marker_path)

	// Reset progress tracking
	save_in_progress = FALSE
	current_save_z_level = 0
	current_save_x = 0
	current_save_y = 0
	counted_areas = list()
	if(!silent)
		to_chat(world, span_boldannounce("World map save finished at [time_stamp()]"))
	log_world("World map save finished at [time_stamp()]")

/// Gets the current progress percentage for the active z-level
/datum/controller/subsystem/persistence/proc/get_current_progress_percent()
	if(!save_in_progress)
		return 0

	var/total_tiles = world.maxx * world.maxy
	var/completed_tiles = (current_save_x * world.maxy) + current_save_y

	return (completed_tiles / total_tiles) * 100

#undef FILE_RECENT_MAPS
#undef KEEP_ROUNDS_MAP
#undef INFINITE_AUTOSAVES
#undef SAVE_COMPLETION_MARKER
