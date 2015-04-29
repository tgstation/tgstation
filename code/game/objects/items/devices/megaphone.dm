/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 2
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "DEATH TO LIZARDS!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!", "VIVA!", "HONK!")

/obj/item/device/megaphone/attack_self(mob/living/carbon/human/user as mob)
	if(user.client)
		if(user.client.prefs.muted & MUTE_IC)
			src << "<span class='warning'>You cannot speak in IC (muted).</span>"
			return

	if(!ishuman(user))
		user << "<span class='warning'>You don't know how to use this!</span>"
		return

	if(spamcheck > world.time)
		user << "<span class='warning'>\The [src] needs to recharge!</span>"
		return

	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return

	message = capitalize(message)
	if(!user.can_speak(message))
		user << "<span class='warning'>You find yourself unable to speak at all!</span>"
		return

	if ((src.loc == user && user.stat == 0))
		if(emagged)
			if(insults)
				user.audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>")
				insults--
			else
				user << "<span class='warning'>*BZZZZzzzzzt*</span>"
		else
			user.audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>")

		playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
		spamcheck = world.time + 50
		return

/obj/item/device/megaphone/emag_act(mob/user)
	user << "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>"
	emagged = 1
	insults = rand(1, 3)	//to prevent dickflooding

/obj/item/device/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"

/obj/item/device/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"

/obj/item/device/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"
