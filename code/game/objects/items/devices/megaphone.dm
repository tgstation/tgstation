/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
<<<<<<< HEAD
	w_class = 2
=======
	w_class = W_CLASS_TINY
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
<<<<<<< HEAD
	var/voicespan = "command_headset" // sic
	var/list/insultmsg = list("FUCK EVERYONE!", "DEATH TO LIZARDS!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!", "VIVA!", "HONK!")

/obj/item/device/megaphone/attack_self(mob/living/carbon/human/user)
	if(user.client)
		if(user.client.prefs.muted & MUTE_IC)
			src << "<span class='warning'>You cannot speak in IC (muted).</span>"
			return

	if(!ishuman(user))
		user << "<span class='warning'>You don't know how to use this!</span>"
		return

	if(spamcheck > world.time)
		user << "<span class='warning'>\The [src] needs to recharge!</span>"
=======
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user as mob)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
	if(!ishuman(user) && (!isrobot(user) || isMoMMI(user))) //Non-humans can't use it, borgs can, mommis can't
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	var/mob/living/carbon/human/H = user
	if(istype(H) && (H.miming || H.silent)) //Humans get their muteness checked
		to_chat(user, "<span class='warning'>You find yourself unable to speak at all.</span>")
		return
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return

	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
<<<<<<< HEAD

	message = capitalize(message)
	if(!user.can_speak(message))
		user << "<span class='warning'>You find yourself unable to speak at all!</span>"
		return

	if ((src.loc == user && user.stat == 0))
		if(emagged)
			if(insults)
				user.say(pick(insultmsg),"machine", list(voicespan))
				insults--
			else
				user << "<span class='warning'>*BZZZZzzzzzt*</span>"
		else
			user.say(message,"machine", list(voicespan))

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

/obj/item/device/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	voicespan = "clown"
=======
	message = capitalize(message)
	if ((src.loc == user && usr.stat == 0))
		if(emagged)
			if(insults)
				for(var/mob/O in (viewers(user)))
					O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>",2) // 2 stands for hearable message
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			for(var/mob/O in (viewers(user)))
				O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2) // 2 stands for hearable message

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
