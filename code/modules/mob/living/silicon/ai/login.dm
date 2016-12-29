/mob/living/silicon/ai/Login()
	..()
	for(var/r in runes)
		var/obj/effect/rune/rune = r
		var/image/blood = image(loc = rune)
		blood.override = 1
		client.images += blood

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
