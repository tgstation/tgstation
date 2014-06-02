/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1
	w_type=NOT_RECYCLABLE

/obj/effect/decal/point/point()
	set src in oview()
	set hidden = 1
	return

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	anchored = 1
	layer = 50

/obj/effect/decal/snow
	name="snow"
	density=0
	anchored=1
	layer=2
	icon='icons/turf/snow.dmi'
	w_type=NOT_RECYCLABLE


/obj/effect/decal/snow/clean/edge
	icon_state="snow_corner"

/obj/effect/decal/snow/sand/edge
	icon_state="gravsnow_corner"

/obj/effect/decal/snow/clean/surround
	icon_state="snow_surround"

/obj/effect/decal/snow/sand/surround
	icon_state="gravsnow_surround"
