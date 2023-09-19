/////////////
//OCEAN BAR//
/////////////

/obj/item/stack/tile/fake_seafloor
	name = "fake ocean floor tiles"
	singular_name = "fake ocean floor tile"
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_seafloor"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fake_seafloor
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fake_seafloor

/turf/open/floor/fake_seafloor
	name = "synthetic ocean floor"
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/tile/fake_seafloor

/turf/open/floor/fake_seafloor/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"

/turf/open/floor/fake_seafloor/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"

/turf/open/floor/fake_seafloor/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"

/turf/closed/mineral/random/fake_ocean
	baseturfs = /turf/open/floor/fake_seafloor
	turf_type = /turf/open/floor/fake_seafloor
	color = "#58606b"
