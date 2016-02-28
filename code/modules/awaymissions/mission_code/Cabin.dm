/*Cabin areas*/
/area/awaymission/snowforest
	name = "Snow Forest"
	icon_state = "away"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/cabin
	name = "Cabin"
	icon_state = "away2"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowforest/lumbermill
	name = "Lumbermill"
	icon_state = "away3"





/*Cabin code*/
/obj/structure/fireplace
	name = "fireplace"
	desc = "warm and toasty"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "fireplace-active"
	density = 0
	var/active = 1

/obj/structure/fireplace/initialize()
	..()
	toggleFireplace()

/obj/structure/fireplace/attack_hand(mob/living/user)
	if(active)
		active = 0
		toggleFireplace()
	else
		..()


/obj/structure/fireplace/attackby(obj/item/W,mob/living/user,params)
	if(!active)
		if(W.is_hot())
			active = 1
			toggleFireplace()
		else
			..()
	else
		W.fire_act()

/obj/structure/fireplace/proc/toggleFireplace()
	if(active)
		SetLuminosity(8)
		icon_state = "fireplace-active"
	else
		SetLuminosity(0)
		icon_state = "fireplace"

/obj/structure/fireplace/extinguish()
	if(active)
		active = 0
		toggleFireplace()


/datum/mapGenerator/snowy
	modules = list(/datum/mapGeneratorModule/snow/pineTrees, \
	/datum/mapGeneratorModule/snow/deadTrees, \
	/datum/mapGeneratorModule/snow/randBushes, \
	/datum/mapGeneratorModule/snow/randIceRocks)

/datum/mapGeneratorModule/snow/checkPlaceAtom(turf/T)
	if(istype(T,/turf/simulated/floor/plating/asteroid/snow))
		return ..(T)
	return 0

/datum/mapGeneratorModule/snow/pineTrees
	spawnableAtoms = list(/obj/structure/flora/tree/pine = 30)

/datum/mapGeneratorModule/snow/deadTrees
	spawnableAtoms = list(/obj/structure/flora/tree/dead = 10)

/datum/mapGeneratorModule/snow/randBushes
	spawnableAtoms = list()

/datum/mapGeneratorModule/snow/randBushes/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/ausbushes)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 1

/datum/mapGeneratorModule/snow/randIceRocks
	spawnableAtoms = list(/obj/structure/flora/rock/icy = 5, /obj/structure/flora/rock/pile/icy = 5)

/obj/effect/landmark/mapGenerator
	var/startTurfX = 0
	var/startTurfY = 0
	var/startTurfZ = -1
	var/endTurfX = 0
	var/endTurfY = 0
	var/endTurfZ = -1
	var/mapGeneratorType = /datum/mapGenerator/nature
	var/datum/mapGenerator/mapGenerator

/obj/effect/landmark/mapGenerator/New()
	..()
	if(startTurfZ < 0)
		startTurfZ = z
	if(endTurfZ < 0)
		endTurfZ = z
	mapGenerator = new mapGeneratorType()
	mapGenerator.defineRegion(locate(startTurfX,startTurfY,startTurfZ), locate(endTurfX,endTurfY,endTurfZ))
	mapGenerator.generate()

/obj/effect/landmark/mapGenerator/snowy
	mapGeneratorType = /datum/mapGenerator/snowy