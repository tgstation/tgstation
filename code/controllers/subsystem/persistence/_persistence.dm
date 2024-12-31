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

#undef FILE_RECENT_MAPS
#undef KEEP_ROUNDS_MAP
