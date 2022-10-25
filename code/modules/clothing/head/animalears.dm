/obj/item/clothing/head/costume/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	color = "#999999"

	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/costume/kitty/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HEAD)
		RegisterSignal(user, COMSIG_CARBON_PRE_MISC_HELP, .proc/on_owner_hug)
	else
		UnregisterSignal(user, COMSIG_CARBON_PRE_MISC_HELP)

/obj/item/clothing/head/costume/kitty/dropped(mob/living/user)
	. = ..()
	UnregisterSignal(user, COMSIG_CARBON_PRE_MISC_HELP)

/obj/item/clothing/head/costume/kitty/visual_equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && (slot & ITEM_SLOT_HEAD))
		update_icon(ALL, user)
		user.update_worn_head() //Color might have been changed by update_appearance.
	..()

/obj/item/clothing/head/costume/kitty/update_icon(updates=ALL, mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		add_atom_colour(user.hair_color, FIXED_COLOUR_PRIORITY)

///signal that fires when the owner is hugged, for special tail pulling (oh no) interactions...?
/obj/item/clothing/head/costume/kitty/proc/on_owner_hug(mob/living/carbon/helped, mob/living/carbon/helper)
	SIGNAL_HANDLER

	if(helper.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return

	helper.visible_message(span_danger("[helper] pulls on [helped]'s tail... and it rips off!"), \
				null, span_hear("You hear a ripping sound."), DEFAULT_MESSAGE_RANGE, list(helper, helped))
	to_chat(helper, span_danger("You pull on [helped]'s tail... and it rips off!"))
	to_chat(helped, span_userdanger("[helper] pulls on your tail... and it rips off!"))
	playsound(helped.loc, 'sound/effects/cloth_rip.ogg', 75, TRUE)
	helped.dropItemToGround(src)
	INVOKE_ASYNC(helper, /mob/proc/put_in_hands, src)
	helper.add_mood_event("rippedtail", /datum/mood_event/rippedtail)
	return COMPONENT_SPECIAL_INTERACTION

/obj/item/clothing/head/costume/kitty/genuine
	desc = "A pair of kitty ears. A tag on the inside says \"Hand made from real cats.\""

/obj/item/clothing/head/costume/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"

	dog_fashion = /datum/dog_fashion/head/rabbit
