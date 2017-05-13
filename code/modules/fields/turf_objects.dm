
/obj/effect/abstract/proximity_checker/advanced/inner
	name = "energy field"
	desc = "Get off my turf!"

/obj/effect/abstract/proximity_checker/advanced/inner/CanPass(atom/movable/AM, turf/target, height)
	if(parent)
		return parent.field_turf_canpass(AM, src, target)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/inner/Crossed(atom/movable/AM)
	if(parent)
		return parent.field_turf_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/inner/Uncross(atom/movable/AM)
	if(parent)
		return parent.field_turf_uncross(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/inner/Uncrossed(atom/movable/AM)
	if(parent)
		return parent.field_turf_uncrossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/edge
	name = "energy field edge"
	desc = "Edgy description here."

/obj/effect/abstract/proximity_checker/advanced/edge/CanPass(atom/movable/AM, turf/target, height)
	if(parent)
		return parent.field_edge_canpass(AM, src, target)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/edge/Crossed(atom/movable/AM)
	if(parent)
		return parent.field_edge_crossed(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/edge/Uncross(atom/movable/AM)
	if(parent)
		return parent.field_edge_uncross(AM, src)
	return TRUE

/obj/effect/abstract/proximity_checker/advanced/edge/Uncrossed(atom/movable/AM)
	if(parent)
		return parent.field_edge_uncrossed(AM, src)
	return TRUE

/proc/is_turf_in_field(turf/T, datum/field/F)	//Looking for ways to optimize this!
	for(var/obj/effect/abstract/proximity_checker/advanced/O in T)
		if(istype(O, /obj/effect/abstract/proximity_checker/advanced/edge))
			if(O.parent == F)
				return FIELD_EDGE
		if(O.parent == F)
			return FIELD_TURF
	return NO_FIELD
