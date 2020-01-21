#define SHORT 5/7
#define TALL 7/5

/datum/element/squish
	element_flags = ELEMENT_DETACH

/datum/element/squish/Attach(datum/target, duration)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/carbon/C = target
	addtimer(CALLBACK(src, .proc/Detach, C, IS_HORIZONTAL(C)), duration)

	C.transform = C.transform.Scale(TALL, SHORT)

/datum/element/squish/Detach(mob/living/carbon/C, was_lying)
	. = ..()
	if(istype(C))
		if(was_lying == IS_HORIZONTAL(C))
			C.transform = C.transform.Scale(SHORT, TALL)
		else
			C.transform = C.transform.Scale(TALL, SHORT)

#undef SHORT
#undef TALL
