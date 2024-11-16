// Restricts to attach more than one sticker to mob
/obj/item/sticker/attempt_attach(atom/target, mob/user)
	if(isliving(target) && COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED))
		balloon_alert_to_viewers("стикер не приклеивается!")
		return FALSE
	return ..()
