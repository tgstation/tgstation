//map elements: areas loaded into the game during runtime
//see: vaults, away missions
var/list/datum/map_element/map_elements = list()

/datum/map_element
	var/name //Name of the map element. Optional
	var/desc //Short description. Optional
	var/type_abbreviation //Very short string that determines the map element's type (whether it's an away mission, a small vault, or something else)

	var/file_path = "maps/randomvaults/new.dmm"

	var/turf/location //A random turf from the map element. Used for jumping to

/datum/map_element/proc/pre_load() //Called before loading the element
	return

/datum/map_element/proc/initialize(list/objects) //Called after loading the element. The "objects" list contains all spawned atoms
	map_elements.Add(src)

	if(objects.len)
		location = locate(/turf) in objects

/datum/map_element/proc/load(x, y, z)
	var/file = file(file_path)
	if(isfile(file))
		pre_load()
		var/list/L = maploader.load_map(file, z, x, y)
		initialize(L)
		return 1

	return 0