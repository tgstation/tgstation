/obj/item/syndicate_beacon
	icon = 'icons/obj/devices/remote.dmi'
	icon_state = "designator_syndicate"

/obj/item/syndicate_beacon/attack_self(mob/user, modifiers)
	. = ..()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_SYNDICATE_SATELLITE)

