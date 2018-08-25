/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/status_display/ai/O in GLOB.ai_status_displays) //change status
		O.mode = 0
		O.update()
	view_core()
