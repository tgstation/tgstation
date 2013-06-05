/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT

	var/spamcheck = 0


/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if (spamcheck)
		return

	playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
	user.visible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")

	spamcheck = 1
	spawn(20)
		spamcheck = 0