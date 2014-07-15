/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user as mob)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
	if(!ishuman(user))
		user << "\red You don't know how to use this!"
		return
	if(user:miming || user.silent)
		user << "\red You find yourself unable to speak at all."
		return
	if(spamcheck)
		user << "\red \The [src] needs to recharge!"
		return

	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
	message = capitalize(message)
	if ((src.loc == user && usr.stat == 0))
		if(emagged)
			if(insults)
				for(var/mob/O in (viewers(user)))
					O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>",2) // 2 stands for hearable message
				insults--
			else
				user << "\red *BZZZZzzzzzt*"
		else
			for(var/mob/O in (viewers(user)))
				O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2) // 2 stands for hearable message

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		user << "\red You overload \the [src]'s voice synthesizer."
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return




/*
	SOUND SYNTH BELOW THIS LINE
----------------------------------------------
*/



/obj/item/device/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

	var/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
	var/sound_flag = 1
	var/list/sound_list
	sound_list=list('sound/items/bikehorn.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/Explosion1.ogg',\
		'sound/mecha/nominal.ogg', 'sound/effects/alert.ogg', 'sound/items/AirHorn.ogg', 'sound/misc/sadtrombone.ogg',\
		'sound/items/Deconstruct.ogg', 'sound/items/Welder.ogg', 'sound/hallucinations/turn_around1.ogg', \
		'sound/machines/ding.ogg', 'sound/effects/awooga.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/twobeep.ogg')
	var/list/sound_names
	sound_names=list("Honk","Bubbles","Boom","Startup","Alert","Airhorn","Trombone",\
		"Construction Noises","Welding Noises", "Creepy Whisper", "Ding", "Awooga", "Flush", "Double Beep")
/*
This is to cycle sounds forward
*/
/obj/item/device/soundsynth/verb/CycleForward()
	set category = "Object"
	set name = "Cycle Sound Forward"
	switch(sound_flag)
		if(12)
			usr << "There is no sound higher then Double Beep!"
			return
		if(0 to 11)
			sound_flag++
			usr << "Sound switched to [sound_names[1+sound_flag]]!"
			return
		else
			sound_flag=0
			return

/*
And backwards
*/
/obj/item/device/soundsynth/verb/CycleBackward()
	set category = "Object"
	set name = "Cycle Sound Backward"

	switch(sound_flag)
		if(0)
			usr << "There is no sound lower then Honk!"
			return
		if(1 to 12)
			sound_flag--
			usr << "Sound switched to [sound_names[1+sound_flag]]!"
			return
		else
			sound_flag=0
			return
/*
This long ass as fuck shit plays the sounds. Im a huge fucking faggot.
If you can make this smaller, please do.
*/

/obj/item/device/soundsynth/attack_self(mob/user as mob)
	if(spam_flag + 20 < world.timeofday)
		var/tmp/playing_sound
		switch(sound_flag)
			if(0 to 12)
				playing_sound = sound_list[sound_flag+1]
			else return
		spam_flag = world.timeofday
		playsound(get_turf(src), playing_sound, 50, 1)
		if(sound_flag == 0) usr << "Honk!"

/obj/item/device/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user) //If you target yourself
		sound_flag++
		if(sound_flag > 12) sound_flag = 0
		usr << "Sound switched to [sound_names[1+sound_flag]]!"
	else
		var/tmp/playing_sound
		switch(sound_flag)
			if(0 to 12)
				playing_sound = sound_list[sound_flag+1]
			else return
		M << playing_sound
