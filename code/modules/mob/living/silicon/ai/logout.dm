/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in GLOB.ai_status_displays) //change status
		O.mode = 0
	view_core()
