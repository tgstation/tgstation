/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 */

/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons = list()

/turf/simulated/floor/mineral/New()
	..()
	broken_states = list("[initial(icon_state)]_dam")

/turf/simulated/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")