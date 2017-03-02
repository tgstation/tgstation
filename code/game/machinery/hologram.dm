/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Any number of AIs can use a holopad. /Lo6
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2
#define RANGE_BASED 4
#define AREA_BASED 6

var/const/HOLOPAD_MODE = RANGE_BASED

var/list/holopads = list()

/obj/machinery/holopad
	name = "\improper AI holopad"
	desc = "It's a floor-mounted device for projecting holographic images. It is activated remotely."
	icon_state = "holopad0"
	layer = LOW_OBJ_LAYER
	flags = HEAR
	languages_spoken = ROBOT | HUMAN
	languages_understood = ROBOT | HUMAN
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	obj_integrity = 300
	max_integrity = 300
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 0)
	var/list/masters = list()//List of AIs that use the holopad
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.
	var/temp = ""

/obj/machinery/holopad/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/holopad(null)
	B.apply_default_parts(src)
	holopads += src

/obj/machinery/holopad/Destroy()
	for (var/mob/living/silicon/ai/master in masters)
		clear_holo(master)
	holopads -= src
	return ..()

/obj/machinery/holo_pad/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= ~NOPOWER

/obj/machinery/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/weapon/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/holopad/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", P))
		return

	if(exchange_parts(user, P))
		return

	if(default_pry_open(P))
		return

	if(default_unfasten_wrench(user, P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/holopad/AltClick(mob/living/carbon/human/user)
	interact(user)

/obj/machinery/holopad/interact(mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return
	if(user.stat || stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat = "<A href='?src=\ref[src];AIrequest=1'>request an AI's presence.</A>"

	var/datum/browser/popup = new(user, "holopad", name, 300, 130)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/holopad/Topic(href, href_list)
	if(..())
		return
	if (href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in living_mob_list)
				if(!AI.client)
					continue
				AI << "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=\ref[src]'>\the [area]</a>.</span>"
		else
			temp = "A request for AI presence was already sent recently.<BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if(href_list["mainmenu"])
		temp = ""

	updateDialog()
	add_fingerprint(usr)

/obj/machinery/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)

/obj/machinery/holopad/process()
	if(masters.len)//If there is a hologram.
		for (var/mob/living/silicon/ai/master in masters)
			if(master && !master.stat && master.client && master.eyeobj)//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
				if(!(stat & NOPOWER))//If the  machine has power.
					if(HOLOPAD_MODE == RANGE_BASED)
						if(get_dist(master.eyeobj, src) <= holo_range)
							return TRUE
						else
							var/obj/machinery/holopad/pad_close = get_closest_atom(/obj/machinery/holopad, holopads, master.eyeobj)
							if(get_dist(pad_close, master.eyeobj) <= holo_range)
								var/obj/effect/overlay/holo_pad_hologram/h = masters[master]
								unset_holo(master)
								pad_close.set_holo(master, h)
								return TRUE

					else if (HOLOPAD_MODE == AREA_BASED)

						var/area/holo_area = get_area(src)
						var/area/eye_area = get_area(master.eyeobj)

						if(eye_area in holo_area.related)
							return TRUE

			clear_holo(master)//If not, we want to get rid of the hologram.
	return TRUE

/obj/machinery/holopad/proc/activate_holo(mob/living/silicon/ai/user)
	if(!(stat & NOPOWER) && user.eyeobj.loc == src.loc)//If the projector has power and client eye is on it
		if (istype(user.current, /obj/machinery/holopad))
			user << "<span class='danger'>ERROR:</span> \black Image feed in progress."
			return
		create_holo(user)//Create one.
		src.visible_message("A holographic image of [user] flicks to life right before your eyes!")
	else
		user << "<span class='danger'>ERROR:</span> \black Unable to project hologram."

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/holopad/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(speaker && masters.len && !radio_freq)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(masters[master] && speaker != master)
				master.relay_speech(message, speaker, message_langs, raw_message, radio_freq, spans)

/obj/machinery/holopad/proc/create_holo(mob/living/silicon/ai/A, turf/T = loc)
	var/obj/effect/overlay/holo_pad_hologram/h = new(T)//Spawn a blank effect at the location.
	h.icon = A.holo_icon
	h.mouse_opacity = 0//So you can't click on it.
	h.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	h.anchored = 1//So space wind cannot drag it.
	h.name = "[A.name] (Hologram)"//If someone decides to right click.
	h.SetLuminosity(2)	//hologram lighting
	set_holo(A, h)
	return TRUE

/obj/machinery/holopad/proc/set_holo(mob/living/silicon/ai/A, var/obj/effect/overlay/holo_pad_hologram/h)
	masters[A] = h
	SetLuminosity(2) // pad lighting
	icon_state = "holopad1"
	A.current = src
	use_power += HOLOGRAM_POWER_USAGE
	return TRUE

/obj/machinery/holopad/proc/clear_holo(mob/living/silicon/ai/user)
	qdel(masters[user]) // Get rid of user's hologram
	unset_holo(user)
	return TRUE

/obj/machinery/holopad/proc/unset_holo(mob/living/silicon/ai/user)
	if(user.current == src)
		user.current = null
	masters -= user // Discard AI from the list of those who use holopad
	use_power = max(HOLOPAD_PASSIVE_POWER_USAGE, use_power - HOLOGRAM_POWER_USAGE)//Reduce power usage
	if (!masters.len) // If no users left
		SetLuminosity(0) // pad lighting (hologram lighting will be handled automatically since its owner was deleted)
		icon_state = "holopad0"
		use_power = HOLOPAD_PASSIVE_POWER_USAGE
	return TRUE

/obj/machinery/holopad/proc/move_hologram(mob/living/silicon/ai/user)
	if(masters[user])
		step_to(masters[user], user.eyeobj)
		var/obj/effect/overlay/holo_pad_hologram/H = masters[user]
		H.loc = get_turf(user.eyeobj)
	return TRUE

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
	return 1

/obj/item/weapon/circuitboard/machine/holopad
	name = "AI Holopad (Machine Board)"
	build_path = /obj/machinery/holopad
	origin_tech = "programming=1"
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

#undef RANGE_BASED
#undef AREA_BASED
#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
