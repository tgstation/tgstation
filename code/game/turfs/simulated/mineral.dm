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

/turf/simulated/floor/mineral/plasma/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/plasma, null)
	..()

//GOLD

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"

/turf/simulated/floor/mineral/gold/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/gold, null)
	..()

//SILVER

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"

/turf/simulated/floor/mineral/silver/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/silver, null)
	..()

//BANANIUM

/turf/simulated/floor/mineral/clown
	name = "bananium floor"
	icon_state = "bananium"

/turf/simulated/floor/mineral/clown/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/clown, null)
	..()

//DIAMOND

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"

/turf/simulated/floor/mineral/diamond/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/diamond, null)
	..()

//URANIUM

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"

/turf/simulated/floor/mineral/uranium/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/uranium, null)
	..()

//PLASTIC

/turf/simulated/floor/mineral/plastic
	name = "plastic floor"
	icon_state = "plastic"

/turf/simulated/floor/mineral/plastic/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/plastic, null)
	..()

//PHAZON

/turf/simulated/floor/mineral/phazon
	name = "phazon floor"
	icon_state = "phazon"

/turf/simulated/floor/mineral/phazon/New()
	floor_tile = getFromPool(/obj/item/stack/tile/mineral/phazon, null)
	..()
