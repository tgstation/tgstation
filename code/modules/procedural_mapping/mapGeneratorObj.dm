/obj/effect/landmark/map_generator
	var/startTurfX = 0
	var/startTurfY = 0
	var/startTurfZ = -1
	var/endTurfX = 0
	var/endTurfY = 0
	var/endTurfZ = -1
	var/mapGeneratorType = /datum/map_generator/nature
	var/datum/map_generator/mapGenerator

/obj/effect/landmark/map_generator/New()
	..()
	if(startTurfZ < 0)
		startTurfZ = z
	if(endTurfZ < 0)
		endTurfZ = z
	mapGenerator = new mapGeneratorType()
	mapGenerator.defineRegion(locate(startTurfX,startTurfY,startTurfZ), locate(endTurfX,endTurfY,endTurfZ))
	mapGenerator.generate()
