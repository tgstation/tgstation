/////////////////
//BEACHSIDE BAR//
/////////////////

/obj/item/paper/fluff/beachside_bar
	name = "lighting system ad"
	default_raw_text = {"With the new Nanotrasen(tm) Magilight Syteme(tm) you too can have perfect lighting at all times of orbit!"}

/obj/item/stack/tile/fakesand
	name = "fake sand tiles"
	singular_name = "fake sand tile"
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_sand"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fakesand
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakesand

/turf/open/floor/fakesand
	name = "synthetic beach"
	desc = "Plastic."
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/fakesand
