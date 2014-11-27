/* Diffrent misc types of tiles & the tile prototype
 * Contains:
 		Tile
 *		Grass
 *		Wood
 *		Carpet
 */

/*
 * Tile
 */
/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	var/turf_type = null

/*
 * Grass
 */
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/fancy/grass

/*
 * Wood
 */
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "an easy to fit wood floor tile."
	icon_state = "tile-wood"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	origin_tech = "biotech=1"
	turf_type = /turf/simulated/floor/wood

/*
 * Carpets
 */
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	turf_type = /turf/simulated/floor/fancy/carpet

/*
 * High-traction
 */
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	w_class = 3.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	turf_type = /turf/simulated/floor/noslip
	origin_tech = "material=3"