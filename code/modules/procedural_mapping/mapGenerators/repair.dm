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
	if(!mother)
		return
	if(mother.z != ZLEVEL_STATION)
		return			//This is only for reloading station blocks!
	var/static/dmm_suite/reloader = new
	reloader.load_map(config.GetFullMapPath(), z_offset = ZLEVEL_STATION, cropMap=TRUE, lower_crop_x = mother.x_low, upper_crop_x = mother.x_high, lower_crop_y = mother.y_low, upper_crop_y = mother.y_high)

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
	modules = list(datum/mapGeneratorModule/bottomLayer/massdelete/no_delete_mobs)
	var/x_low = 0
	var/x_high = 0
	var/y_low = 0
	var/y_high = 0
	var/z = 0
	var/cleanload = FALSE
	var/datum/mapGeneratorModule/reload_station_map/loader

/datum/mapGenerator/repair/reload_station_map/clean
	cleanload = TRUE

/datum/mapGenerator/repair/reload_station_map/defineRegion(turf/start, turf/end)
	. = ..()
	if(start.z != ZLEVEL_STATION || end.z != ZLEVEL_STATION)
		return
	if(start.x > end.x || start.y > end.y)
		var/turf/temp = start
		start = end
		end = temp
	x_low = start.x
	y_low = start.y
	x_high = end.x
	y_high = end.x
	z = ZLEVEL_STATION

/datum/mapGenerator/repair/reload_station_map/generate(clean = cleanload)
	if(!loader)
		loader = new
	if(cleanload)
		..()			//Trigger mass deletion.
	modules |= loader
	syncModules()
	loader.generate(clean)
