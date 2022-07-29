/obj/item/clothing/head/garland
	name = "floral garland"
	desc = "Someone, somewhere, is starving while wearing this. And it's definitely not you."
	icon_state = "garland"
	worn_icon_state = "garland"

/obj/item/clothing/head/garland/equipped(mob/user, slot)
	. = ..()
	if(slot_flags & slot)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "garland", /datum/mood_event/garland)

/obj/item/clothing/head/garland/dropped(mob/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "garland")
