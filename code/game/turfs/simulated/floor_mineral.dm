
/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/last_event = 0
	var/active = null

/turf/simulated/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	mineral = "plasma"
	floortype = "plasma"
	floor_tile = new/obj/item/stack/tile/mineral/plasma

/turf/simulated/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	mineral = "gold"
	floortype = "gold"
	floor_tile = new/obj/item/stack/tile/mineral/gold

/turf/simulated/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	mineral = "silver"
	floortype = "silver"
	floor_tile = new/obj/item/stack/tile/mineral/silver

/turf/simulated/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	mineral = "bananium"
	floortype = "bananium"
	floor_tile = new/obj/item/stack/tile/mineral/bananium

/turf/simulated/floor/mineral/bananium/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	mineral = "diamond"
	floortype = "diamond"
	floor_tile = new/obj/item/stack/tile/mineral/diamond

/turf/simulated/floor/mineral/uranium
	name = "uranium floor"
	icon_state = "uranium"
	mineral = "uranium"
	floortype = "uranium"
	floor_tile = new/obj/item/stack/tile/mineral/uranium