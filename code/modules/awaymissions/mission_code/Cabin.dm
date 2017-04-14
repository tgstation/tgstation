
/obj/structure/firepit
	name = "firepit"
	desc = "warm and toasty"
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "firepit-active"
	density = 0
	var/active = 1

/obj/structure/firepit/Initialize()
	..()
	toggleFirepit()

/obj/structure/firepit/attack_hand(mob/living/user)
	if(active)
		active = 0
		toggleFirepit()
	else
		..()

/obj/structure/firepit/attackby(obj/item/W,mob/living/user,params)
	if(!active)
		var/msg = W.ignition_effect(src, user)
		if(msg)
			active = TRUE
			visible_message(msg)
			toggleFirepit()
		else
			return ..()
	else
		W.fire_act()

/obj/structure/firepit/proc/toggleFirepit()
	if(active)
		set_light(8)
		icon_state = "firepit-active"
	else
		set_light(0)
		icon_state = "firepit"

/obj/structure/firepit/extinguish()
	if(active)
		active = FALSE
		toggleFirepit()

/obj/structure/firepit/fire_act(exposed_temperature, exposed_volume)
	if(!active)
		active = TRUE
		toggleFirepit()



//other Cabin Stuff//

/obj/machinery/recycler/lumbermill
	name = "lumbermill saw"
	desc = "Faster then the cartoons!"
	emagged = 2 //Always gibs people
	item_recycle_sound = 'sound/weapons/chainsawhit.ogg'

/obj/machinery/recycler/lumbermill/recycle_item(obj/item/weapon/grown/log/L)
	if(!istype(L))
		return
	else
		var/potency = L.seed.potency
		..()
		new L.plank_type(src.loc, 1 + round(potency / 25))

/mob/living/simple_animal/chicken/rabbit/normal
	icon_state = "b_rabbit"
	icon_living = "b_rabbit"
	icon_dead = "b_rabbit_dead"
	icon_prefix = "b_rabbit"
	minbodytemp = 0
	eggsleft = 0
	egg_type = null
	speak = list()

/*Cabin's forest*/
/datum/mapGenerator/snowy
	modules = list(/datum/mapGeneratorModule/bottomlayer/snow, \
	/datum/mapGeneratorModule/snow/pineTrees, \
	/datum/mapGeneratorModule/snow/deadTrees, \
	/datum/mapGeneratorModule/snow/randBushes, \
	/datum/mapGeneratorModule/snow/randIceRocks, \
	/datum/mapGeneratorModule/snow/bunnies)

/datum/mapGeneratorModule/snow/checkPlaceAtom(turf/T)
	if(istype(T,/turf/open/floor/plating/asteroid/snow))
		return ..(T)
	return 0

/datum/mapGeneratorModule/bottomlayer/snow
	spawnableTurfs = list(/turf/open/floor/plating/asteroid/snow/atmosphere = 100)

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

/datum/mapGeneratorModule/snow/bunnies
	//spawnableAtoms = list(/mob/living/simple_animal/chicken/rabbit/normal = 0.1)
	spawnableAtoms = list(/mob/living/simple_animal/chicken/rabbit = 0.5)

/datum/mapGeneratorModule/snow/randIceRocks
	spawnableAtoms = list(/obj/structure/flora/rock/icy = 5, /obj/structure/flora/rock/pile/icy = 5)

/obj/effect/landmark/mapGenerator/snowy
	mapGeneratorType = /datum/mapGenerator/snowy
	endTurfX = 159
	endTurfY = 157
	startTurfX = 37
	startTurfY = 35
