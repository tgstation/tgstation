// Dump winterball tiles here

/turf/open/floor/plating/snowed/smoothed/notfrozen
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS //see defs/atmospherics.dm

/turf/open/floor/plating/snowed/roof
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/temple
	name = "Temple Tile"
	desc = ""
	icon = 'icons/turf/floors/elder_floors.dmi'
	icon_state = "elder_pristine_slab"
	baseturfs = /turf/open/indestructible/temple
	tiled_dirt = FALSE

/turf/open/indestructible/temple/corner
	icon_state = "elder_pristine_tile"

/turf/open/indestructible/temple/side
	icon_state = "elder_pristine_block"

/turf/open/indestructible/temple/circle
	icon_state = "elder_pristine_surrounding"

/turf/open/indestructible/temple/circle/side
	icon_state = "elder_pristine_surroundingtile"

/turf/open/indestructible/cobble
	name = "cobblestone path"
	desc = "A simple but beautiful path made of various sized stones."
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble"
	baseturfs = /turf/open/indestructible/cobble
	tiled_dirt = FALSE

/turf/open/indestructible/cobble/side
	icon_state = "cobble_side"

/turf/open/indestructible/cobble/corner
	icon_state = "cobble_corner"