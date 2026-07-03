/// Maximum amount of squishes for mob to prevent infinite squishing
#define MAXIMUM_SQUISHES 3

/mob/living/carbon
	/// Used in squish amount restriction
	var/squish_counter = 0

/datum/element/squish/Attach(datum/target, duration=20 SECONDS, reverse=FALSE)
	var/mob/living/carbon/C = target
	// Restricts duplicating element to prevent very x/y-sized mobs
	if(C.squish_counter >= MAXIMUM_SQUISHES)
		return FALSE
	C.squish_counter++
	return ..()

/datum/element/squish/Detach(mob/living/carbon/C, was_lying, reverse)
	. = ..()
	if(C && C.squish_counter >= 0)
		C.squish_counter--

#undef MAXIMUM_SQUISHES
