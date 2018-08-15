/obj/structure/booth_seating
	name = "booth seating"
	desc = "Comfortable <i>and</i> snazzy."
	icon = 'icons/superbox/booth_seating.dmi'
	icon_state = "booth"
	anchored = TRUE
	can_buckle = 0
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	layer = OBJ_LAYER
	density = TRUE

/obj/structure/booth_seating/end
	icon_state = "end"

/obj/structure/booth_seating/Initialize()
	. = ..()
	add_overlay(mutable_appearance(icon, "[icon_state]_overlay", layer=ABOVE_MOB_LAYER))

/obj/structure/booth_seating/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return 1
	if(get_dir(loc, target) & turn(dir, 180))
		return !density
	return 1

/obj/structure/booth_seating/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && (O.pass_flags & PASSGLASS))
		return 1
	if(get_dir(O, target) & turn(dir, 180))
		return !density
	return 1
