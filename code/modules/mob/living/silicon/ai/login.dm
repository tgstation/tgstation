/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()
	for(var/obj/effect/rune/rune in world)
		var/image/blood = image(loc = rune)
		blood.override = 1
		client.images += blood
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()