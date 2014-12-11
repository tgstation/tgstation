
//**************************************************************
// Map Datum -- Metaclub
//**************************************************************

/datum/map/active
	nameShort = "meta"
	nameLong = "Meta Club"
	tDomeX = 128
	tDomeY = 69
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spaceEmpty1" ;
			},
		/datum/zLevel/space{
			name = "spaceEmpty2" ;
			},
		)

////////////////////////////////////////////////////////////////

#include "metaclub.dmm"
