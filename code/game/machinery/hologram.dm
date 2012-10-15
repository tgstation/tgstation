/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Only one AI may project from a holopad at any given time.
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/

// HOLOPAD MODE
// 0 = RANGE BASED
// 1 = AREA BASED
var/const/HOLOPAD_MODE = 0


/obj/machinery/hologram/holopad/attack_hand(var/mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return
	if(alert(user,"Would you like to request an AI's presence?",,"Yes","No") == "Yes")
		if(last_request + 200 < world.time) //don't spam the AI with requests you jerk!
			last_request = world.time
			user << "<span class='notice'>You request an AI's presence.</span>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in living_mob_list)
				if(!AI.client)	continue
				AI << "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=\ref[src]'>\the [area]</a>.</span>"
		else
			user << "<span class='notice'>A request for AI presence was already sent recently.</span>"

/obj/machinery/hologram/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!hologram)//If there is no hologram, possibly make one.
		activate_holo(user)
	else if(master==user)//If there is a hologram, remove it. But only if the user is the master. Otherwise do nothing.
		clear_holo()
	return

/obj/machinery/hologram/holopad/proc/activate_holo(mob/living/silicon/ai/user)
	if(!(stat & NOPOWER) && user.eyeobj.loc == src.loc)//If the projector has power and client eye is on it.
		if(!hologram)//If there is not already a hologram.
			create_holo(user)//Create one.
			src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
		else
			user << "\red ERROR: \black Image feed in progress."
	else
		user << "\red ERROR: \black Unable to project hologram."
	return

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/hologram/holopad/hear_talk(mob/M, text)
	if(M&&hologram&&master)//Master is mostly a safety in case lag hits or something.
		if(!master.say_understands(M))//The AI will be able to understand most mobs talking through the holopad.
			text = stars(text)
		var/name_used = M.name
		if(istype(M.wear_mask, /obj/item/clothing/mask/gas/voice)&&M.wear_mask:vchange)//Can't forget the ninjas.
			name_used = M.wear_mask:voice
		//This communication is imperfect because the holopad "filters" voices and is only designed to connect to the master only.
		var/rendered = "<i><span class='game say'>Holopad received, <span class='name'>[name_used]</span> <span class='message'>[M.say_quote(text)]</span></span></i>"
		master.show_message(rendered, 2)
	return

/obj/machinery/hologram/holopad/proc/create_holo(mob/living/silicon/ai/A, turf/T = loc)
	hologram = new(T)//Spawn a blank effect at the location.
	hologram.icon = A.holo_icon
	hologram.mouse_opacity = 0//So you can't click on it.
	hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	hologram.anchored = 1//So space wind cannot drag it.
	hologram.name = "[A.name] (Hologram)"//If someone decides to right click.
	hologram.SetLuminosity(2)	//hologram lighting
	SetLuminosity(2)			//pad lighting
	icon_state = "holopad1"
	A.current = src
	master = A//AI is the master.
	use_power = 2//Active power usage.
	return 1

/obj/machinery/hologram/holopad/proc/clear_holo()
//	hologram.SetLuminosity(0)//Clear lighting.	//handled by the lighting controller when its ower is deleted
	del(hologram)//Get rid of hologram.
	if(master.current == src)
		master.current = null
	master = null//Null the master, since no-one is using it now.
	SetLuminosity(0)			//pad lighting (hologram lighting will be handled automatically since its owner was deleted)
	icon_state = "holopad0"
	use_power = 1//Passive power usage.
	return 1

/obj/machinery/hologram/holopad/process()
	if(hologram)//If there is a hologram.
		if(master && !master.stat && master.client && master.eyeobj)//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
			if(!(stat & NOPOWER))//If the  machine has power.
				if((HOLOPAD_MODE == 0 && (get_dist(master.eyeobj, src) <= holo_range)))
					return 1

				else if (HOLOPAD_MODE == 1)

					var/area/holo_area = get_area(src)
					var/area/eye_area = get_area(master.eyeobj)

					if(eye_area in holo_area.master.related)
						return 1

		clear_holo()//If not, we want to get rid of the hologram.
	return 1

/obj/machinery/hologram/holopad/proc/move_hologram()
	if(hologram)
		step_to(hologram, master.eyeobj) // So it turns.
		hologram.loc = get_turf(master.eyeobj)

	return 1

/obj/machinery/hologram/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= ~NOPOWER

//Destruction procs.
/obj/machinery/hologram/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(5))
				del(src)
	return

/obj/machinery/hologram/blob_act()
	del(src)
	return

/obj/machinery/hologram/meteorhit()
	del(src)
	return

/obj/machinery/hologram/Del()
	if(hologram)
		src:clear_holo()
	..()

/*
Holographic project of everything else.

/mob/verb/hologram_test()
	set name = "Hologram Debug New"
	set category = "CURRENT DEBUG"

	var/obj/effect/overlay/hologram = new(loc)//Spawn a blank effect at the location.
	var/icon/flat_icon = icon(getFlatIcon(src,0))//Need to make sure it's a new icon so the old one is not reused.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/input = input("Select what icon state to use in effect.",,"")
	if(input)
		var/icon/alpha_mask = new('icons/effects/effects.dmi', "[input]")
		flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
		hologram.icon = flat_icon

		world << "Your icon should appear now."
	return
*/