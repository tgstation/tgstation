//MINERAL FLOORS ARE HERE
//Includes: PLASMA, GOLD, SILVER, BANANIUM, DIAMOND, URANIUM, PHAZON

//PLASMA

/turf/simulated/floor/mineral/New()
	if(floor_tile)
		material = floor_tile.material
	..()

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma

/turf/simulated/floor/mineral/plasma/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/plasma, null)
	..()

//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold

/turf/simulated/floor/mineral/gold/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/gold, null)
	..()

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver

/turf/simulated/floor/mineral/silver/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/silver, null)
	..()

//BANANIUM

/turf/simulated/floor/mineral/clown
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/clown

/turf/simulated/floor/mineral/clown/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/clown, null)
	..()

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond

/turf/simulated/floor/mineral/diamond/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/diamond, null)
	..()

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium

/turf/simulated/floor/mineral/uranium/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/uranium, null)
	..()

//PLASTIC

/turf/simulated/floor/mineral/plastic
	name = "plastic floor"
	icon_state = "plastic"
	floor_tile = /obj/item/stack/tile/mineral/plastic

/turf/simulated/floor/mineral/plastic/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/plastic, null)
	..()

//PHAZON

/turf/simulated/floor/mineral/phazon
	name = "phazon floor"
	icon_state = "phazon"
	floor_tile = /obj/item/stack/tile/mineral/phazon

/turf/simulated/floor/mineral/phazon/New()
	if(floor_tile)
		returnToPool(floor_tile)
		floor_tile = null
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/phazon, null)
	..()
