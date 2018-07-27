/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/loaded = 0 // Times loaded this round
	var/static/datum/maploader/maploader = new

/datum/map_template/New(path = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath)
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/datum/parsed_map/parsed = maploader.load_map(file(path), 1, 1, 1, cropMap=FALSE, measureOnly=TRUE)
	var/bounds = parsed?.bounds
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/load_new_z()
	var/x = round((world.maxx - width)/2)
	var/y = round((world.maxy - height)/2)

	var/datum/space_level/level = SSmapping.add_new_zlevel(name, list(ZTRAIT_AWAY = TRUE))
	var/datum/parsed_map/parsed = maploader.load_map(file(mappath), x, y, level.z_value, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE)
	var/list/bounds = parsed.bounds
	if(!bounds)
		return FALSE

	repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()
	smooth_zlevel(world.maxz)
	log_game("Z-level [name] loaded at at [x],[y],[world.maxz]")

	return level

/datum/map_template/proc/load(turf/T, centered = FALSE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/datum/parsed_map/parsed = maploader.load_map(file(mappath), T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE)
	var/list/bounds = parsed?.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load
	parsed.initTemplateBounds()

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	return bounds

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


//for your ever biggening badminnery kevinz000
//❤ - Cyberboss
/proc/load_new_z_level(var/file, var/name)
	var/datum/map_template/template = new(file, name)
	template.load_new_z()
