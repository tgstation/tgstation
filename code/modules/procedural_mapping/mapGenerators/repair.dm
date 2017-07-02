/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel
	spawnableTurfs = list(/turf/open/floor/plasteel = 100)
	var/ignore_wall = FALSE
	allowAtomsOnSpace = TRUE

/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/place(turf/T)
	if(isclosedturf(T) && !ignore_wall)
		return FALSE
	return ..()

/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten
	ignore_wall = TRUE

/datum/mapGeneratorModule/border/normalWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall = 100)
	allowAtomsOnSpace = TRUE

/datum/mapGeneratorModule/reload_station_map/generate()
	if(!istype(mother, /datum/mapGenerator/repair/reload_station_map))
		to_chat(usr, "<span class='warning'>ABORTING: Wrong parent mapGenerator type.</span>")
		return
	var/datum/mapGenerator/repair/reload_station_map/mother1 = mother
	if(mother1.z != ZLEVEL_STATION)
		to_chat(usr, "<span class='warning'>ABORTING: Zlevel not on station.</span>")
		return			//This is only for reloading station blocks!
	GLOB.reloading_map = TRUE
	var/static/dmm_suite/reloader = new
	var/list/bounds = reloader.load_map(file(SSmapping.config.GetFullMapPath()),measureOnly = FALSE, no_changeturf = FALSE,x_offset = 0, y_offset = 0, z_offset = ZLEVEL_STATION, cropMap=TRUE, lower_crop_x = mother1.x_low, lower_crop_y = mother1.y_low, upper_crop_x = mother1.x_high, upper_crop_y = mother1.y_high)

	to_chat(usr, "<span class='boldnotice'>LOADING COMPLETE: BLOCK [bounds[MAP_MINX]]/[bounds[MAP_MINY]]/[bounds[MAP_MINZ]] TO [bounds[MAP_MAXX]]/[bounds[MAP_MAXY]]/[bounds[MAP_MAXZ]]. INITIALIZING ATOMS.</span>")

	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()

	repopulate_sorted_areas()

	for(var/L in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
	                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		set waitfor = FALSE
		var/turf/B = L
		atoms += B
		for(var/A in B)
			atoms += A
			if(istype(A,/obj/structure/cable))
				cables += A
				continue
			if(istype(A,/obj/machinery/atmospherics))
				atmos_machines += A

	SSatoms.InitializeAtoms(atoms)
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	to_chat(usr, "<span class='boldnotice'>Loading Complete.</span>")
	GLOB.reloading_map = FALSE

/datum/mapGenerator/repair
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/repair/delete_walls
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/repair/enclose_room
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten,
	/datum/mapGeneratorModule/border/normalWalls,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/repair/reload_station_map
	modules = list(/datum/mapGeneratorModule/bottomLayer/massdelete/no_delete_mobs)
	var/x_low = 0
	var/x_high = 0
	var/y_low = 0
	var/y_high = 0
	var/z = 0
	var/cleanload = FALSE
	var/datum/mapGeneratorModule/reload_station_map/loader

/datum/mapGenerator/repair/reload_station_map/clean
	cleanload = TRUE

/datum/mapGenerator/repair/reload_station_map/clean/in_place
	modules = list(/datum/mapGeneratorModule/bottomLayer/massdelete/regeneration_delete)

/datum/mapGenerator/repair/reload_station_map/defineRegion(turf/start, turf/end)
	. = ..()
	if(start.z != ZLEVEL_STATION || end.z != ZLEVEL_STATION)
		return
	x_low = min(start.x, end.x)
	y_low = min(start.y, end.y)
	x_high = max(start.x, end.x)
	y_high = max(start.y, end.y)
	z = ZLEVEL_STATION

GLOBAL_VAR_INIT(reloading_map, FALSE)

/datum/mapGenerator/repair/reload_station_map/generate(clean = cleanload)
	to_chat(usr, "<span class='notice'>Generating [x_low]/[y_low] to [x_high]/[y_high] with zlevel [z] and cleanload [cleanload]</span>")
	if(!loader)
		loader = new
	if(cleanload)
		to_chat(usr, "<span class='notice'>Mass deleting area.</span>")
		..()			//Trigger mass deletion.
	modules |= loader
	syncModules()
	to_chat(usr, "<span class='notice'>Starting loader.</span>")
	loader.generate()
