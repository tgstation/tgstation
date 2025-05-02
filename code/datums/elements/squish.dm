#define SHORT 5/7
#define TALL 7/5

/**
 * squish.dm
 *
 * It's an element that squishes things. After the duration passes, it reverses the transformation it squished with, taking into account if they are a different orientation than they started (read: rotationally-fluid)
 *
 * Normal squishes apply vertically, as if the target is being squished from above, but you can set horizontal_squish to TRUE if you want to squish them from the sides, like if they pancake into a wall from the East or West
*/
/datum/element/squish
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/squish/Attach(atom/target, duration=20 SECONDS, horizontal_squish=FALSE)
	. = ..()

	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/was_lying = FALSE
	if(iscarbon(target))
		var/mob/living/carbon/carboniucus = target
		was_lying = carboniucus.body_position == LYING_DOWN
	addtimer(CALLBACK(src, PROC_REF(Detach), target, was_lying, horizontal_squish), duration)

	if(horizontal_squish)
		target.transform = target.transform.Scale(SHORT, TALL)
	else
		target.transform = target.transform.Scale(TALL, SHORT)

/datum/element/squish/Detach(atom/target, was_lying, horizontal_squish)
	. = ..()
	var/is_lying = FALSE
	if(iscarbon(target))
		var/mob/living/carbon/carboniucus = target
		is_lying = carboniucus.body_position == LYING_DOWN

	if(horizontal_squish)
		is_lying = !is_lying

	if(was_lying == is_lying)
		target.transform = target.transform.Scale(SHORT, TALL)
	else
		target.transform = target.transform.Scale(TALL, SHORT)

#undef SHORT
#undef TALL
