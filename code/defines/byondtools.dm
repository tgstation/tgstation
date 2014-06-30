/**
* Markers and shit used with BYONDTools.
*
* Mostly just used in mapping.
*/

/obj/effect/byondtools/changed
	icon='icons/effects/tile_effects.dmi'
	icon_state="changed"
	layer = LIGHTING_LAYER
	alpha = 64
	color = "#ff0000"

/obj/effect/byondtools/changed/New()
	layer = TURF_LAYER
	warning("Some dipshit left a [type] at [x],[y],[z].  Might want to fix that (dmmfix map.dmm)")
	del(src)