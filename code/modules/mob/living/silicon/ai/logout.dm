/mob/living/silicon/ai/Logout()
	..()
	for(var/each in GLOB.ai_status_displays) //change status
		var/obj/machinery/status_display/ai/O = each
		O.mode = 0
		O.update()
	if(eyeobj)
		eyeobj.invisibility = initial(invisibility)
		eyeobj.mouse_opacity = initial(mouse_opacity)
	view_core()
