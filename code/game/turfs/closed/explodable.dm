/turf/closed/indestructible/explodable // Child of indestructible as we want to be indestructible to anything that isn't explosions
	name = "wall"
	desc = "Effectively impervious to most conventional methods of destruction. It looks like an explosion might knock it down."
	icon = 'icons/turf/walls.dmi'
	baseturfs = /turf/open/floor/plating
	explosive_resistance = 1

/turf/closed/indestructible/explodable/ex_act(severity, target)
	ScrapeAway()
	return TRUE

/turf/closed/indestructible/explodable/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance('icons/turf/overlays.dmi', "explodable", layer+0.1))

/turf/closed/indestructible/explodable/riveted
	icon = 'icons/turf/walls/riveted.dmi'
	icon_state = "riveted-0"
	base_icon_state = "riveted"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
