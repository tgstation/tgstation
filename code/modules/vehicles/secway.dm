
/obj/vehicle/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/vehicle/secway/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/secway