
//**************************************************************
// Map Datum -- Ministation
//**************************************************************

/datum/map/active
	nameShort = "mini"
	nameLong = "Ministation"
	tDomeX = 128
	tDomeY = 76
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/mining,
		)

////////////////////////////////////////////////////////////////

#include "ministation.dmm"

#if !defined(MAP_OVERRIDE_FILES)
	#define MAP_OVERRIDE_FILES
	#include "ministation\misc.dm"
	#include "ministation\telecomms.dm"
	#include "ministation\uplink_item.dm"
	#include "ministation\job\jobs.dm"
	#include "ministation\job\removed.dm"

//#elif !defined(MAP_OVERRIDE)
	//#warn a map has already been included, ignoring ministation.
