/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	origin_tech = "magnets=1;combat=1"
	w_class = 1.0
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0//just in case

/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if (spamcheck)
		return

	if(emagged)
		if(insults >= 1)
			playsound(get_turf(src), 'sound/voice/binsult.ogg', 100, 1, vary = 0)//hueheuheuheuheuheuhe
			user.visible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.\"</span>", \
								"<span class='warning'>Your [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.\"</span>", \
								"<span class='warning'>You hear the computerized voice of a security hailer: \"FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHITFUCK. EAT PENISES IN YOUR FUCKFACE AND SHIT OUT ABORTIONS OF FUCK AND DO A SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.\"</span>")
			insults--
		else
			to_chat(user, "<span class='warning'>*BZZZZcuntZZZZT*</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
		user.visible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>", \
							"<span class='warning'>Your [name] rasps, \"Halt! Security!\"</span>", \
							"<span class='warning'>You hear the computerized voice of a security hailer: \"Halt! Security!\"</span>")

	spamcheck = 1
	spawn(20)
		spamcheck = 0

/obj/item/device/hailer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return
