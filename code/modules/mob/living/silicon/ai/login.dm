/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	client.screen.len = 0
	client.images.len = 0
	for(var/obj/effect/rune/rune in world)
		var/image/blood = image(loc = rune)
		blood.override = 1
		client.images += blood
	..()
	regenerate_icons()
	flash = new /obj/screen( null )
	flash.icon_state = "blank"
	flash.name = "flash"
	flash.screen_loc = "1,1 to 15,15"
	flash.layer = 17
	blind = new /obj/screen( null )
	blind.icon_state = "black"
	blind.name = " "
	blind.screen_loc = "1,1 to 15,15"
	blind.layer = 0
	client.screen += list( blind, flash )
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in world) //change status
			if(O)
				O.mode = 1
				O.emotion = "Neutral"
	return