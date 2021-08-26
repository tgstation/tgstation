
/obj/effect/abstract/proximity_checker/advanced
	name = "field"
	desc = "Why can you see energy fields?!"
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	flags_1 = ON_BORDER_1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/proximity_monitor/advanced/parent = null

/obj/effect/abstract/proximity_checker/advanced/Initialize(mapload, _monitor)
	if(_monitor)
		parent = _monitor
	. = ..()

/obj/effect/abstract/proximity_checker/advanced/center
	name = "field anchor"
	desc = "No."

/obj/effect/abstract/proximity_checker/advanced/field_turf
	name = "energy field"
	desc = "Get off my turf!"

/obj/effect/abstract/proximity_checker/advanced/field_turf/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(parent)
		return parent.field_turf_canpass(mover, src, border_dir)

/obj/effect/abstract/proximity_checker/advanced/field_turf/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(parent)
		return parent.field_turf_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_turf/on_uncrossed(datum/source, atom/movable/gone, direction)
	. = ..()
	if(parent)
		return parent.field_turf_uncrossed(gone, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge
	name = "energy field edge"
	desc = "Edgy description here."

/obj/effect/abstract/proximity_checker/advanced/field_edge/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(parent)
		return parent.field_edge_canpass(mover, src, border_dir)

/obj/effect/abstract/proximity_checker/advanced/field_edge/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(parent)
		return parent.field_edge_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/field_edge/on_uncrossed(datum/source, atom/movable/gone, direction)
	if(parent)
		return parent.field_edge_uncrossed(gone, src)
	return TRUE

/proc/is_turf_in_field(turf/T, datum/proximity_monitor/advanced/F) //Looking for ways to optimize this!
	for(var/obj/effect/abstract/proximity_checker/advanced/O in T)
		if(istype(O, /obj/effect/abstract/proximity_checker/advanced/field_edge))
			if(O.parent == F)
				return FIELD_EDGE
		if(O.parent == F)
			return FIELD_TURF
	return FALSE
