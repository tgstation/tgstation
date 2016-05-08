/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null
	var/loaded = 0 // Times loaded this round

/datum/map_template/New(path = null, map = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	var/bounds = maploader.load_map(file(path), 1, 1, 1, cropMap=FALSE, measureOnly=TRUE)
	if(bounds)
		width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
		height = bounds[MAP_MAXY]
	return bounds

/datum/map_template/proc/load(turf/T, centered = FALSE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/bounds = maploader.load_map(get_file(), T.x, T.y, T.z, cropMap=TRUE)
	if(!bounds)
		return 0

	//initialize things that are normally initialized after map load
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()

	for(var/L in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
	                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		var/turf/B = L
		for(var/A in B)
			atoms += A
			if(istype(A,/obj/structure/cable))
				cables += A
				continue
			if(istype(A,/obj/machinery/atmospherics))
				atmos_machines += A
				continue

	SSobj.setup_template_objects(atoms)
	SSmachine.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	return 1

/datum/map_template/proc/get_file()
	if(mapfile)
		. = mapfile
	else if(mappath)
		. = file(mappath)

	if(!.)
		world.log << "The file of [src] appears to be empty/non-existent."

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


/proc/preloadTemplates(path = "_maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadRuinTemplates()
	preloadShuttleTemplates()

/proc/preloadRuinTemplates()
	var/list/potentialSpaceRuins = generateMapList(filename = "_maps/RandomRuins/SpaceRuins/_maplisting.txt", blacklist = "config/spaceRuinBlacklist.txt")
	for(var/ruin in potentialSpaceRuins)
		var/datum/map_template/T = new(path = "[ruin]", rename = "[ruin]")
		space_ruins_templates[T.name] = T
		map_templates[T.name] = T

	var/list/potentialLavaRuins = generateMapList(filename = "_maps/RandomRuins/LavaRuins/_maplisting.txt", blacklist = "config/lavaRuinBlacklist.txt")
	for(var/ruin in potentialLavaRuins)
		var/datum/map_template/T = new(path = "[ruin]", rename = "[ruin]")
		lava_ruins_templates[T.name] = T
		map_templates[T.name] = T

/proc/preloadShuttleTemplates()
	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()

		shuttle_templates[S.name] = S
		map_templates[S.name] = S
