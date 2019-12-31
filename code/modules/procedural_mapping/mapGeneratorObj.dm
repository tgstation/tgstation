/obj/effect/landmark/mapGenerator
	var/startTurfX = ZERO
	var/startTurfY = ZERO
	var/startTurfZ = -1
	var/endTurfX = ZERO
	var/endTurfY = ZERO
	var/endTurfZ = -1
	var/mapGeneratorType = /datum/mapGenerator/nature
	var/datum/mapGenerator/mapGenerator

/obj/effect/landmark/mapGenerator/New()
	..()
	if(startTurfZ < ZERO)
		startTurfZ = z
	if(endTurfZ < ZERO)
		endTurfZ = z
	mapGenerator = new mapGeneratorType()
	mapGenerator.defineRegion(locate(startTurfX,startTurfY,startTurfZ), locate(endTurfX,endTurfY,endTurfZ))
	mapGenerator.generate()
