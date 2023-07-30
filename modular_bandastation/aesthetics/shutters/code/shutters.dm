/obj/machinery/door/poddoor/shutters
	// icon = 'modular_bandastation/aesthetics/shutters/icons/shutters.dmi' // TG already uses these
	var/door_open_sound = 'modular_bandastation/aesthetics/shutters/sound/shutters_open.ogg'
	var/door_close_sound = 'modular_bandastation/aesthetics/shutters/sound/shutters_close.ogg'

/obj/machinery/door/poddoor/shutters/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, door_open_sound, 50, TRUE)
		if("closing")
			flick("closing", src)
			playsound(src, door_close_sound, 50, TRUE)
