/mob/living/silicon/ai/Login()
	..()
	if(stat != DEAD)
		for(var/obj/machinery/status_display/ai/O in GLOB.ai_status_displays) //change status
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
	if(multicam_on)
		end_multicam()
	view_core()
