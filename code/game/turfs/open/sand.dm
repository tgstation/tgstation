/turf/open/misc/beach
	name = "beach"
	desc = "Sandy."
	icon = 'icons/misc/beach.dmi'
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/beach/ex_act(severity, target)
	return FALSE

/turf/open/misc/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "sand"
	base_icon_state = "sand"
	baseturfs = /turf/open/misc/beach/sand

/turf/open/misc/beach/coastline_t
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"
	base_icon_state = "sandwater_t"
	baseturfs = /turf/open/misc/beach/coastline_t

/turf/open/misc/beach/sand/coastline_t/break_tile()
	. = ..()
	icon_state = "sandwater_t"

/turf/open/misc/beach/coastline_t/sandwater_inner
	icon_state = "sandwater_inner"

/turf/open/misc/beach/coastline_b //need to make this water subtype.
	name = "coastline"
	icon_state = "sandwater_b"
	base_icon_state = "sandwater_b"
	baseturfs = /turf/open/misc/beach/coastline_b
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/open/misc/beach/sand/coastline_b/break_tile()
	. = ..()
	icon_state = "sandwater_b"

/turf/open/misc/sandy_dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/misc/sandy_dirt/break_tile()
	. = ..()
	icon_state = "sand_damaged"

/turf/open/misc/ironsand
	gender = PLURAL
	name = "iron sand"
	desc = "Like sand, but more <i>iron</i>."
	icon_state = "ironsand1"
	base_icon_state = "ironsand1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"
