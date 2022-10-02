/obj/item/clothing/head/garland
	name = "floral garland"
	desc = "Someone, somewhere, is starving while wearing this. And it's definitely not you."
	icon_state = "garland"
	worn_icon_state = "garland"

/obj/item/clothing/head/garland/equipped(mob/living/user, slot)
	. = ..()
	if(slot_flags & slot)
		user.add_mood_event("garland", /datum/mood_event/garland)

/obj/item/clothing/head/garland/dropped(mob/living/user)
	. = ..()
	user.clear_mood_event("garland")
