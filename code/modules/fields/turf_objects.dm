
/atom/movable/field_object
	name = "field"
	desc = "Why can you see energy fields?!"
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	flags = ABSTRACT|ON_BORDER
	var/datum/field/parent = null

/atom/movable/field_object/New(newparent = null)
	if(!isnull(newparent))
		parent = newparent
	return ..()

/atom/movable/field_object/field_turf
	name = "energy field"
	desc = "Get off my turf!"

/atom/movable/field_object/field_turf/CanPass(atom/movable/AM, turf/target, height)
	if(parent)
		return parent.field_turf_canpass(AM, src, target)
	return TRUE

/atom/movable/field_object/field_turf/Crossed(atom/movable/AM)
	if(parent)
		return parent.field_turf_crossed(AM, src)
	return TRUE

/atom/movable/field_object/field_turf/Uncross(atom/movable/AM)
	if(parent)
		return parent.field_turf_uncross(AM, src)
	return TRUE

/atom/movable/field_object/field_turf/Uncrossed(atom/movable/AM)
	if(parent)
		return parent.field_turf_uncrossed(AM, src)
	return TRUE

/atom/movable/field_object/field_edge
	name = "energy field edge"
	desc = "Edgy description here."

/atom/movable/field_object/field_edge/CanPass(atom/movable/AM, turf/target, height)
	if(parent)
		return parent.field_edge_canpass(AM, src, target)
	return TRUE

/atom/movable/field_object/field_edge/Crossed(atom/movable/AM)
	if(parent)
		return parent.field_edge_crossed(AM, src)
	return TRUE

/atom/movable/field_object/field_edge/Uncross(atom/movable/AM)
	if(parent)
		return parent.field_edge_uncross(AM, src)
	return TRUE

/atom/movable/field_object/field_edge/Uncrossed(atom/movable/AM)
	if(parent)
		return parent.field_edge_uncrossed(AM, src)
	return TRUE

/proc/is_turf_in_field(turf/T, datum/field/F)	//Looking for ways to optimize this!
	for(var/atom/movable/field_object/O in T)
		if(istype(O, /atom/movable/field_object/field_edge))
			if(O.parent == F)
				return FIELD_EDGE
		if(O.parent == F)
			return FIELD_TURF
	return NO_FIELD
