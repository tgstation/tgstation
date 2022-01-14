/obj/modular_map_root
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	icon_state = "pinonclose"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

	/// List of map templates which can be attached to this root
	var/list/modules = list()

/obj/modular_map_root/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, .proc/load_map)

/obj/modular_map_root/proc/load_map()
	var/turf/spawn_area = get_turf(src)

	var/datum/map_template/map_module/map = new()

	var/mapfile = pick(modules)

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

	preload_size(mappath)

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
