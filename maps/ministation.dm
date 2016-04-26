
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
