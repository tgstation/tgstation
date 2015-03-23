/obj/item/device/voice_synthesizer
	name = "voice synthesizer"
	desc = "A small, nondescript object used to produce vocalizations from text using a holographic keyboard. A label reads, \"DENI T2S SPEAKER\"."
	icon_state = "memorizerburnt"
	w_class = 2
	slot_flags = SLOT_BELT
	force = 3
	throwforce = 1
	m_amt = 50
	g_amt = 50
	var/speaking_icon = "memorizer2"
	var/idle_icon = "memorizerburnt"
	var/speech = "I don't know you! Who are you? You're no guest of mine!"

/obj/item/device/voice_synthesizer/attack_self()
	SayStuff(usr)

/obj/item/device/voice_synthesizer/AltClick(var/mob/user)
	..()
	if(in_range(user, src) && user.canmove && !user.stat && ishuman(user) && !user.restrained())
		SayStuff(user)

/obj/item/device/voice_synthesizer/proc/SayStuff(mob/user)
	speech = stripped_input(user, "What do you want to say?", "Voice Synthesizer Keyboard", "")
	if(!speech)
		return
	icon_state = speaking_icon
	say(speech)
	playsound(loc, 'sound/machines/click.ogg', 30, 1)
	sleep(20)
	playsound(loc, 'sound/machines/click.ogg', 30, 1)
	icon_state = idle_icon

/obj/item/device/voice_synthesizer/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click or activate in hand to use it.</span>"

/obj/item/device/voice_synthesizer/tape
	desc = "A standard voice synthesizer designed to look like an old-style tape recorder. It has a label: \"Made in Miami\"."
	icon_state = "voicesynth"
	speaking_icon = "voicesynth_active"
	idle_icon = "voicesynth"
