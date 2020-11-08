
/obj/machinery/computer
	var/clicksound = "keyboard"
	var/clickvol = 40
	var/next_clicksound

/obj/machinery/computer/interact(mob/user, special_state)
	. = ..()
	if(clicksound && world.time > next_clicksound && isliving(user))
		next_clicksound = world.time + 5
		playsound(src, get_sfx_skyrat(clicksound), clickvol)

/obj/machinery/computer/ui_interact(mob/user, datum/tgui/ui)
	if(clicksound && world.time > next_clicksound && isliving(user))
		next_clicksound = world.time + 5
		playsound(src, get_sfx_skyrat(clicksound), clickvol)
	. = ..()

/proc/get_sfx_skyrat(soundin)
	if(istext(soundin))
		switch(soundin)
			if("keyboard")
				soundin = pick('modular_skyrat/modules/aesthetics/computer/sound/keypress1.ogg','modular_skyrat/modules/aesthetics/computer/sound/keypress2.ogg','modular_skyrat/modules/aesthetics/computer/sound/keypress3.ogg','modular_skyrat/modules/aesthetics/computer/sound/keypress4.ogg', 'modular_skyrat/modules/aesthetics/computer/sound/keystroke4.ogg')
	return soundin
