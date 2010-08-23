/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/send_hear()
	if (src.listening)
		return hearers(7, src.loc)
