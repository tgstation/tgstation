/obj/structure/liquid_barrier
	name = "liquid barrier"
	desc = "A complex draining mesh embedded in the flooring that blocks any and all liquids from passing through.\n<i>You feel like these were installed for a very good reason...</i>"
	icon = 'monkestation/icons/obj/structures/drains.dmi'
	icon_state = "bigdrain"
	plane = FLOOR_PLANE
	layer = GAS_SCRUBBER_LAYER
	density = FALSE
	anchored = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/liquid_barrier/Initialize(mapload)
	. = ..()
	if(mapload && !isfloorturf(loc))
		log_mapping("[src] mapped onto a non-floor turf at [AREACOORD(src)]!")
	var/static/list/loc_connections = list(
		COMSIG_TURF_LIQUIDS_CREATION = PROC_REF(on_liquid_creation),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_BLOCK_LIQUID_SPREAD)))

/obj/structure/liquid_barrier/proc/on_liquid_creation(datum/source)
	SIGNAL_HANDLER
	return BLOCK_LIQUID_CREATION
