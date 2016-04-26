// Workaround for verbs not being sent to mobs with !istype(loc, /turf)
// Permission to steal concept from Bay12 granted by Zuhayr 9/17/2015
// (Probably not really needed, but having your ass covered is a good thing.)

/**
 * Verb Holder
 *
 * Used for sending verbs to mobs that don't have a turf loc.
 */
/obj/item/verbs
	name = "verb holder"
	desc = "You shouldn't see this."

	density=0

// Then you just slap verbs in here and send_verbs(mob).
// Done.