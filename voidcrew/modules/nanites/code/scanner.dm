/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'voidcrew/modules/nanites/icons/device.dmi'
	icon_state = "nanite_scanner"
	inhand_icon_state = "nanite_hypo"
	worn_icon_state = "nanite_hypo"
	lefthand_file = 'voidcrew/modules/nanites/icons/nanite_lefthand.dmi'
	righthand_file = 'voidcrew/modules/nanites/icons/nanite_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/target, mob/living/carbon/human/user)
	user.visible_message(
		span_notice("[user] analyzes [target]'s nanites."),
		span_notice("You analyze [target]'s nanites."),
	)

	add_fingerprint(user)

	var/response = SEND_SIGNAL(target, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, span_info("No nanites detected in the subject."))
