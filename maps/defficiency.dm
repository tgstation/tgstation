
//**************************************************************
// Map Datum -- Defficiency
//**************************************************************

/datum/map/active
	nameShort = "deff"
	nameLong = "Defficiency"
	map_dir = "defficiency"
	tDomeX = 127
	tDomeY = 67
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
			name = "spaceEmpty" ;
			},
		)


//The central shuttle leads to both outposts
/datum/map/active/New()
	.=..()

	mining_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on defficiency now - the asteroid shuttle
	mining_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

/obj/structure/docking_port/destination/mining/station
	areaname = "main station dock"

/obj/structure/docking_port/destination/mining/outpost
	areaname = "mining outpost"

/datum/shuttle/mining/initialize()
	.=..()
	add_dock(/obj/structure/docking_port/destination/mining/station)
	add_dock(/obj/structure/docking_port/destination/mining/outpost)
	add_dock(/obj/structure/docking_port/destination/research/outpost)

//All security airlocks have randomized wires
/obj/machinery/door/airlock/glass_security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/obj/machinery/door/airlock/security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

////////////////////////////////////////////////////////////////
#include "defficiency/pipes.dm" // Atmos layered pipes.

#include "defficiency/areas.dm" // Areas

#include "defficiency.dmm"
