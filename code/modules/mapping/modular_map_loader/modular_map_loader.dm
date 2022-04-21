/obj/modular_map_root
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonclose"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

	/// Points to a .toml file storing configuration data about the modules associated with this root
	var/config_file = null
	/// Used for off-repo modular maps. Give a list of valid http links and one is picked at random to be requested.
	var/external_map_urls = list()
	/// The off-repo modular map that was picked and fetched from one of the above links.
	var/external_map_file
	/// Key used to look up the appropriate map paths in the associated .toml file
	var/key = null
	/// If we load from an external http link, defaults to FALSE
	var/load_from_external = FALSE

INITIALIZE_IMMEDIATE(/obj/modular_map_root)

/obj/modular_map_root/proc/get_external_map()
	var/picked_url = pick(external_map_urls)
	var/static/query_in_progress = FALSE
	if(query_in_progress)
		UNTIL(!query_in_progress)
	log_asset("Modular map fetching custom map from: [picked_url]")
	var/datum/http_request/request = new()
	var/file_name = "tmp/custom_modular_map.dmm"
	request.prepare(RUSTG_HTTP_METHOD_GET, picked_url, "", "", file_name)
	query_in_progress = TRUE
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		query_in_progress = FALSE
		CRASH("Failed to fetch custom modular map from url: [picked_url], code: [response.status_code], error: [response.error]")
	external_map_file = file(file_name)
	query_in_progress = FALSE
	log_asset("External modular map loaded: [external_map_file]")
	return TRUE

/obj/modular_map_root/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, .proc/load_map)

/// Randonly selects a map file from the TOML config specified in config_file, loads it, then deletes itself.
/obj/modular_map_root/proc/load_map()
	var/turf/spawn_area = get_turf(src)

	var/datum/map_template/map_module/map = new()

	if(load_from_external)
		if(!get_external_map())
			return

	if(!config_file && !load_from_external)
		return

	if(!key && !load_from_external)
		return

	var/config = rustg_read_toml_file(config_file)

	var/mapfile
	if(load_from_external)
		mapfile = "[external_map_file]"
	else
		mapfile = config["directory"] + pick(config["rooms"][key]["modules"])

	map.load(spawn_area, FALSE, mapfile)

	qdel(src, force=TRUE)

/datum/map_template/map_module
	name = "Base Map Module Template"

	var/x_offset = 0
	var/y_offset = 0

/datum/map_template/map_module/load(turf/T, centered = FALSE, mapfile = null)

	if(!mapfile)
		return

	mappath = mapfile

	preload_size(mappath) // We need to run this here as the map path has been null until now

	T = locate(T.x - x_offset, T.y - y_offset, T.z)
	. = ..()

/datum/map_template/map_module/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	var/list/offset = discover_offset(/obj/modular_map_connector)

	x_offset = offset[1] - 1
	y_offset = offset[2] - 1

	if(!cache)
		cached_map = null

/obj/modular_map_connector
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonclose"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
