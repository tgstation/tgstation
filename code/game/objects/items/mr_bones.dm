/obj/item/mr_bones_voice_box // Why not include it in anyways?
	name = "voice box"
	desc = "It sounds like an early era Source game."
	icon = 'icons/obj/storage.dmi'
	icon_state = "voicebox"
	inhand_icon_state = "voicebox"
	mouse_opacity = 0
	var/list/bone_phrases = list("ERROR: Incorrect Answer","Roleplay","No","Solve the Riddle","Repeat","Your Problem")

/obj/item/mr_bones_voice_box/attack_self(mob/user)
	var/choice = input(user, "Select Your Phrase", "Mr.Bones Rattler 3000") as null|anything in bone_phrases

	switch(choice)
		if("ERROR: Incorrect Answer")
			playsound(user, 'sound/voice/mrbones/error_incorrect.ogg', 50)
			user.say("ERROR: Incorrect answer.")
		if("Solve the Riddle")
			playsound(user, 'sound/voice/mrbones/solve_the_riddle.ogg', 50)
			user.say("You need to solve the riddle.")
		if("Repeat")
			playsound(user, 'sound/voice/mrbones/repeat.ogg', 50)
			user.say("Repeat your answer, please.")
		if("Roleplay")
			playsound(user, 'sound/voice/mrbones/roleplay.ogg', 50)
			user.say("Please roleplay appropriately, ok.")
		if("Your Problem")
			playsound(user, 'sound/voice/mrbones/your_problem_buddy.ogg', 50)
			user.say("That's your problem, buddy.")
		if("No")
			playsound(user, 'sound/voice/mrbones/no.ogg', 50)
			user.say("No.")
	new /obj/effect/temp_visual/source_mic(get_turf(user))


//haha MMM was using the fluff structures meant solely for decor purposes and giving them UTILITY FUCK ME
/obj/structure/fluff/spooky_skeleton
	name = "spooky skeleton"
	desc = "Spooked ya!"
	icon = 'icons/obj/fluff.dmi'
	icon_state = "spookedya2"
	deconstructible = FALSE
	max_integrity = 9999
	var/active = FALSE
	var/spook_var //identification used by the pressure plate
	var/x_axis = TRUE //determines whether animate uses pixel x/y, false means pixel y
	var/pixel_distance = 32 //distance in pixels for animate, negative values are fine
	var/popup_time = 5 //how long it takes to reach the end of the animatiom
	var/popup_delay = 30 //the delay between the skeleton fully popping out and receeding into the wall again

/obj/structure/fluff/spooky_skeleton/Initialize()
	. = ..()
	GLOB.spooky_skeletons += src
	layer = 2

/obj/structure/fluff/spooky_skeleton/Destroy()
	GLOB.spooky_skeletons.Remove(src)
	return ..()

/obj/structure/fluff/spooky_skeleton/proc/spook()
	active = TRUE
	playsound(src, 'sound/misc/SpookedYa.ogg', 50)
	if(x_axis)
		animate(src, pixel_x = pixel_distance, time = popup_time, easing = LINEAR_EASING)
		layer = initial(layer)
		sleep(popup_delay)
		animate(src, pixel_x = initial(pixel_x), time = popup_time, easing = LINEAR_EASING)
		active = FALSE
		layer = 2
	else
		animate(src, pixel_y = pixel_distance, time = popup_time, easing = LINEAR_EASING)
		layer = initial(layer)
		sleep(popup_delay)
		animate(src, pixel_y = initial(pixel_y), time = popup_time, easing = LINEAR_EASING)
		layer = 2
		active = FALSE

/obj/effect/spooky_skeleton_pressurepad
	name = "spooky pressure plate"
	desc = "Capable of activating far and distant spooks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_open"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	var/spook_var

/obj/effect/spooky_skeleton_pressurepad/Crossed()
	. = ..()
	if(spook_var)
		for(var/obj/structure/fluff/spooky_skeleton/S in GLOB.spooky_skeletons)
			if (S.spook_var == spook_var)
				if(!S.active)
					S.spook()