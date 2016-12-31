/mob/living/silicon/ai/Login()
	..()
	for(var/r in ai_hidden_runes)
		invisify_rune(r)

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in machines) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
