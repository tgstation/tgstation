
/datum/mapGenerator

	//Map information
	var/list/map = list()

	//mapGeneratorModule information
	var/list/modules = list()

/datum/mapGenerator/New()
	..()
	initialiseModules()

//Defines the region the map represents, sets map
//Returns the map
/datum/mapGenerator/proc/defineRegion(var/turf/Start, var/turf/End)
	if(!checkRegion(Start, End))
		return 0

	map = block(Start,End)
	return map


//Defines the region the map represents, as a CIRCLE!, sets map
//Returns the map
/datum/mapGenerator/proc/defineCircularRegion(var/turf/Start, var/turf/End)
	if(!checkRegion(Start, End))
		return 0

	var/centerX = abs(max(End.x-Start.x,1))
	var/centerY = abs(max(End.y-Start.y,1))
	var/centerZ = abs(max(End.z-Start.z,1))
	var/radius = abs(max(centerX,centerY)) //take the biggest displacement as the radius

	var/turf/center = locate(centerX, centerY, centerZ) //spherical maps! because Idk

	map = circlerange(center,radius)
	return map


//Checks for and Rejects bad region coordinates
//Returns 1/0
/datum/mapGenerator/proc/checkRegion(var/turf/Start, var/turf/End)
	. = 1

	if(!Start || !End)
		return 0 //Just bail

	if(Start.x > world.maxx || End.x > world.maxx)
		. = 0
	if(Start.y > world.maxy || End.y > world.maxy)
		. = 0
	if(Start.z > world.maxz || End.z > world.maxz)
		. = 0


//Requests the mapGeneratorModule(s) to (re)generate
/datum/mapGenerator/proc/generate()
	set background = 1 //this can get beefy

	syncModules()
	if(!modules || !modules.len)
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		mod.generate()


//Requests the mapGeneratorModule(s) to (re)generate this one turf
/datum/mapGenerator/proc/generateOneTurf(var/turf/T)
	if(!T)
		return
	syncModules()
	if(!modules || !modules.len)
		return
	for(var/datum/mapGeneratorModule/mod in modules)
		mod.place(T)


//Replaces all paths in the module list with actual module datums
/datum/mapGenerator/proc/initialiseModules()
	for(var/path in modules)
		if(ispath(path))
			modules.Remove(path)
			modules |= new path
	syncModules()


//Sync mapGeneratorModule(s) to mapGenerator
/datum/mapGenerator/proc/syncModules()
	for(var/datum/mapGeneratorModule/mod in modules)
		mod.sync(src)



///////////////////////////
// HERE BE DEBUG DRAGONS //
///////////////////////////

/client/proc/debugNatureMapGenerator()
	set name = "Test Nature Map Generator"
	set category = "Debug"

	var/datum/mapGenerator/nature/N = new()
	var/startInput = input(usr,"Start turf of Map, (X;Y;Z)", "Map Gen Settings", "1;1;1") as text
	var/endInput = input(usr,"End turf of Map (X;Y;Z)", "Map Gen Settings", "[world.maxx];[world.maxy];[mob ? mob.z : 1]") as text
	//maxx maxy and current z so that if you fuck up, you only fuck up one entire z level instead of the entire universe
	if(!startInput || !endInput)
		src << "Missing Input"
		return

	var/list/startCoords = text2list(startInput, ";")
	var/list/endCoords = text2list(endInput, ";")
	if(!startCoords || !endCoords)
		src << "Invalid Coords"
		src << "Start Input: [startInput]"
		src << "End Input: [endInput]"
		return

	var/turf/Start = locate(text2num(startCoords[1]),text2num(startCoords[2]),text2num(startCoords[3]))
	var/turf/End = locate(text2num(endCoords[1]),text2num(endCoords[2]),text2num(endCoords[3]))
	if(!Start || !End)
		src << "Invalid Turfs"
		src << "Start Coords: [startCoords[1]] - [startCoords[2]] - [startCoords[3]]"
		src << "End Coords: [endCoords[1]] - [endCoords[2]] - [endCoords[3]]"
		return

	src << "Defining Region"
	N.defineRegion(Start, End)
	src << "Region Defined"
	src << "Generating Region"
	N.generate()
	src << "Generated Region"

