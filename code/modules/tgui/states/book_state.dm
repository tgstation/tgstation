/**
 * tgui state: book_state
 *
 * A state specifically intended for book or book-like objects.
 * Checks for state related to being able to read.
 */
GLOBAL_DATUM_INIT(book_state, /datum/ui_state/book, new)

/datum/ui_state/book/can_use_topic(src_object, mob/user)
	if(!user.can_read(src_object))
		return UI_CLOSE
	if(user.is_blind())
		return UI_CLOSE

	if(user.incapacitated)
		return UI_UPDATE

	if(isitem(src_object))
		var/obj/item/book = src_object
		if(book.resistance_flags & ON_FIRE)
			return UI_CLOSE

	if(isatom(src_object))
		var/atom/booklike = src_object
		if(booklike.IsReachableBy(user))
			return UI_INTERACTIVE
		if(get_dist(user, booklike) <= 2)
			if(iscarbon(user))
				var/mob/living/carbon/carbon_user = user
				if(carbon_user.dna?.check_mutation(/datum/mutation/telekinesis))
					return UI_INTERACTIVE
			return UI_UPDATE
		return UI_CLOSE

	return UI_INTERACTIVE
