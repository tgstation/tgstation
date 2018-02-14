/datum/mapGeneratorModule/bottomLayer/cultFloor
	spawnableTurfs = list(/turf/open/floor/engine/cult = 100)

/datum/mapGeneratorModule/border/cultWalls
	spawnableTurfs = list(/turf/closed/wall/mineral/cult = 100)

/datum/mapGeneratorModule/bottomLayer/chumbisFloor
	spawnableTurfs = list(/turf/open/floor/chumbiswork = 100)

/datum/mapGeneratorModule/border/chumbisWalls
	spawnableTurfs = list(/turf/closed/wall/chumbiswork = 100)

/datum/mapGenerator/cult //walls and floor only
	modules = list(/datum/mapGeneratorModule/bottomLayer/cultFloor, \
		/datum/mapGeneratorModule/border/cultWalls, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
	buildmode_name = "Pattern: Cult Room"

/datum/mapGenerator/chumbis //walls and floor only
	modules = list(/datum/mapGeneratorModule/bottomLayer/chumbisFloor, \
		/datum/mapGeneratorModule/border/chumbisWalls, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
	buildmode_name = "Pattern: chumbiswork Room"

/datum/mapGenerator/cult/floor //floors only
	modules = list(/datum/mapGeneratorModule/bottomLayer/cultFloor, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
	buildmode_name = "Block: Cult Floor"

/datum/mapGenerator/chumbis/floor //floor only
	modules = list(/datum/mapGeneratorModule/bottomLayer/chumbisFloor, \
		/datum/mapGeneratorModule/bottomLayer/repressurize)
	buildmode_name = "Block: chumbiswork Floor"
