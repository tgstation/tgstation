/turf/open/misc/beach
	name = "beach"
	desc = "Sandy."
	icon = 'icons/turf/sand.dmi'
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/misc/beach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/sand)

/turf/open/misc/beach/ex_act(severity, target)
	return FALSE

/turf/open/misc/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "sand"
	base_icon_state = "sand"
	baseturfs = /turf/open/misc/beach/sand

/turf/open/misc/beach/sand/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "sand[rand(1,4)]"

/turf/open/misc/beach/coast
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon = 'icons/turf/beach.dmi'
	icon_state = "beach"
	base_icon_state = "beach"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/misc/beach/coast/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/turf/open/misc/beach/coast/break_tile()
	. = ..()
	icon_state = "beach"

/turf/open/misc/beach/coast/corner
	icon_state = "beach-corner"
	base_icon_state = "beach-corner"

/turf/open/misc/beach/coast/corner/break_tile()
	. = ..()
	icon_state = "beach-corner"

/turf/open/misc/sandy_dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	damaged_dmi = 'icons/turf/damaged.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/misc/sandy_dirt/break_tile()
	. = ..()
	icon_state = "sand_damaged"

/turf/open/misc/sandy_dirt/broken_states()
	return list("sand_damaged")

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
