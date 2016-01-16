/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()
	for(var/obj/effect/rune/rune in rune_list) //HOLY FUCK WHO THOUGHT LOOPING THROUGH THE WORLD WAS A GOOD IDEA
		client.images += rune.blood_image
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	src.view_core()
	return