/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma. This can only end well."
	icon_state = "tile_plasma"
	origin_tech = "plasmatech=1"
	turf_type = /turf/open/floor/mineral/plasma
	mineralType = "plasma"
	materials = list(MAT_PLASMA=500)

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. You feel a bit woozy."
	icon_state = "tile_uranium"
	turf_type = /turf/open/floor/mineral/uranium
	mineralType = "uranium"
	materials = list(MAT_URANIUM=500)

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "A tile made out of gold, the swag seems strong here."
	icon_state = "tile_gold"
	turf_type = /turf/open/floor/mineral/gold
	mineralType = "gold"
	materials = list(MAT_GOLD=500)

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "A tile made out of silver, the light shining from it is blinding."
	icon_state = "tile_silver"
	turf_type = /turf/open/floor/mineral/silver
	mineralType = "silver"
	materials = list(MAT_SILVER=500)

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "A tile made out of diamond. Wow, just, wow."
	icon_state = "tile_diamond"
	origin_tech = "materials=2"
	turf_type = /turf/open/floor/mineral/diamond
	mineralType = "diamond"
	materials = list(MAT_DIAMOND=500)

/obj/item/stack/tile/mineral/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	turf_type = /turf/open/floor/mineral/bananium
	mineralType = "bananium"
	materials = list(MAT_BANANIUM=500)

/obj/item/stack/tile/mineral/abductor
	name = "alien floor tile"
	singular_name = "alien floor tile"
	desc = "A tile made out of alien alloy."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	origin_tech = "materials=6;abductor=1"
	turf_type = /turf/open/floor/mineral/abductor
	mineralType = "abductor"

/obj/item/stack/tile/mineral/titanium
	name = "titanium tile"
	singular_name = "titanium floor tile"
	desc = "A tile made of titanium, used for shuttles."
	icon_state = "tile_shuttle"
	origin_tech = "materials=2"
	turf_type = /turf/open/floor/mineral/titanium
	mineralType = "titanium"
	materials = list(MAT_TITANIUM=500)

/obj/item/stack/tile/mineral/plastitanium
	name = "plas-titanium tile"
	singular_name = "plas-titanium floor tile"
	desc = "A tile made of plas-titanium, used for very evil shuttles."
	icon_state = "tile_darkshuttle"
	origin_tech = "materials=2"
	turf_type = /turf/open/floor/mineral/plastitanium
	mineralType = "plastitanium"
	materials = list(MAT_TITANIUM=250, MAT_PLASMA=250)