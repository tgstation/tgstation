/obj/structure/guncase/plasma
	name = "plasma rifle locker"
	desc = "A locker that holds plasma rifles. Only opens in dire emergencies."
	icon_state = "ecase"
	case_type = "egun"
	gun_category = /obj/item/gun/energy/plasma
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //because fuck you, powergaming nerds.

/obj/structure/guncase/plasma/attackby(obj/item/W, mob/user, params)
	return

/obj/structure/guncase/plasma/MouseDrop(over_object, src_location, over_location)
	if(GLOB.security_level == SEC_LEVEL_RED || GLOB.security_level == SEC_LEVEL_DELTA)
		. = ..()
	else
		to_chat(usr, "The storage unit will only unlock during a Red or Delta security alert.")

/obj/structure/guncase/plasma/attack_hand(mob/user)
	return MouseDrop(user)

/obj/structure/guncase/plasma/emag_act()
	to_chat(usr, "The locking mechanism is fitted with old style parts, The card has no effect.")
	return