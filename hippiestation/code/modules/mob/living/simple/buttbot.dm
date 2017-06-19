/mob/living/simple_animal/bot/buttbot
	name = "buttbot"
	desc = "It's a robotic butt. Are you dense or something??"
	icon = 'hippiestation/icons/obj/butts.dmi'
	icon_state = "buttbot"
	layer = 5.0
	density = 0
	anchored = 0
	flags = HEAR
	health = 25
	var/xeno = 0 //Do we hiss when buttspeech?
	var/cooldown = 0
	var/list/speech_buffer = list()
	var/list/speech_list = list("butt.", "butts.", "ass.", "fart.", "assblast usa", "woop get an ass inspection", "woop") //Hilarious.

/mob/living/simple_animal/bot/buttbot/Initialize()
	..()
	if(xeno)
		icon_state = "buttbot_xeno"
		speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")

/mob/living/simple_animal/bot/buttbot/explode()
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/T = get_turf(src)

	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(T)
	if(xeno)
		new /obj/item/organ/butt/xeno(T)
	else
		new /obj/item/organ/butt(T)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	// new /obj/effect/decal/cleanable/blood/oil(loc)
	..() //qdels us and removes us from processing objects

/mob/living/simple_animal/bot/buttbot/handle_automated_action()
	if (!..())
		return

	if(isturf(src.loc))
		var/anydir = pick(GLOB.cardinal)
		if(Process_Spacemove(anydir))
			Move(get_step(src, anydir), anydir)

	if(prob(5) && cooldown < world.time)
		cooldown = world.time + 200 //20 seconds
		if(xeno) //Hiss like a motherfucker
			playsound(loc, "hiss", 15, 1, 1)
		if(prob(70) && speech_buffer.len)
			speak(buttificate(pick(speech_buffer)))
			if(prob(5))
				speech_buffer.Remove(pick(speech_buffer)) //so they're not magic wizard guru buttbots that hold arcane information collected during an entire round.
		else
			speak(pick(speech_list))

/mob/living/simple_animal/bot/buttbot/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also dont imitate ourselves. Imitate other buttbots though heheh
	if(speaker != src && prob(40))
		if(speech_buffer.len >= 20)
			speech_buffer -= pick(speech_buffer)
		speech_buffer |= html_decode(raw_message)
	..()