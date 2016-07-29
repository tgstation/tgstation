<<<<<<< HEAD
/mob/living/silicon/ai/Login()
	..()
	for(var/obj/effect/rune/rune in world)
		var/image/blood = image(loc = rune)
		blood.override = 1
		client.images += blood

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
