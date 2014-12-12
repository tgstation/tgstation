
//**************************************************************
//
// Map Datums
// --------------
// Each map can have its own datum now. This means no more
// hardcoded bullshit. Same for each Z-level.
//
// Should be mostly self-explanatory. Define /datum/map/active
// in your map file. See current maps for examples.
//
//**************************************************************

/datum/map
	var/nameShort = ""
	var/nameLong = ""
	var/list/zLevels = list()
	var/zMainStation = 1
	var/zCentcomm = 2

	//Center of thunderdome admin room
	var/tDomeX = 0
	var/tDomeY = 0
	var/tDomeZ = 0

/datum/map/New()
	. = ..()
	src.zLevels = src.loadZLevels(src.zLevels)
	return

/datum/map/proc/loadZLevels(list/levelPaths)
	var/levels = list()
	for(var/path in levelPaths)
		levels += new path
	return levels

////////////////////////////////////////////////////////////////

/datum/zLevel
	var/name = ""
	var/teleJammed = 0

////////////////////////////////

/datum/zLevel/station
	name = "station"

/datum/zLevel/centcomm
	name = "centcomm"
	teleJammed = 1

/datum/zLevel/space
	name = "space"

/datum/zLevel/mining
	name = "mining"

// Debug ///////////////////////////////////////////////////////

/*
/mob/verb/getCurMapData()
	src << "\nCurrent map data:"
	src << "* Short name: [map.nameShort]"
	src << "* Long name: [map.nameLong]"
	src << "* Z-levels: [map.zLevels]"
	src << "* Main station Z: [map.zMainStation]"
	src << "* Centcomm Z: [map.zCentcomm]"
	src << "* Thunderdome coords: ([map.tDomeX],[map.tDomeY],[map.tDomeZ])\n"
	return
*/
