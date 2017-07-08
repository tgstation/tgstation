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
#define HOLOPAD_MODE RANGE_BASED

/obj/machinery/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	layer = LOW_OBJ_LAYER
	flags = HEAR
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	obj_integrity = 300
	max_integrity = 300
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 0)
	var/list/masters = list()//List of living mobs that use the holopad
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.
	var/temp = ""
	var/list/holo_calls	//array of /datum/holocalls
	var/datum/holocall/outgoing_call	//do not modify the datums only check and call the public procs
	var/static/force_answer_call = FALSE	//Calls will be automatically answered after a couple rings, here for debugging
	var/static/list/holopads = list()

/obj/machinery/holopad/Initialize()
	. = ..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/holopad(null)
	B.apply_default_parts(src)
	holopads += src

/obj/machinery/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.ConnectionFailure(src)

	for (var/I in masters)
		clear_holo(I)
	holopads -= src
	return ..()

/obj/machinery/holopad/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)

/obj/machinery/holopad/obj_break()
	. = ..()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

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
	if(isAI(user))
		hangup_all_calls()
		return

/obj/machinery/holopad/interact(mob/living/carbon/human/user) //Carn: Hologram requests.
	if(!istype(user))
		return

	if(outgoing_call || user.incapacitated() || !is_operational())
		return

	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat = "<a href='?src=\ref[src];AIrequest=1'>Request an AI's presence.</a><br>"
		dat += "<a href='?src=\ref[src];Holocall=1'>Call another holopad.</a><br>"

		if(LAZYLEN(holo_calls))
			dat += "=====================================================<br>"

		var/one_answered_call = FALSE
		var/one_unanswered_call = FALSE
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad != src)
				dat += "<a href='?src=\ref[src];connectcall=\ref[HC]'>Answer call from [get_area(HC.calling_holopad)].</a><br>"
				one_unanswered_call = TRUE
			else
				one_answered_call = TRUE

		if(one_answered_call && one_unanswered_call)
			dat += "=====================================================<br>"
		//we loop twice for formatting
		for(var/I in holo_calls)
			var/datum/holocall/HC = I
			if(HC.connected_holopad == src)
				dat += "<a href='?src=\ref[src];disconnectcall=\ref[HC]'>Disconnect call from [HC.user].</a><br>"


	var/datum/browser/popup = new(user, "holopad", name, 300, 130)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

//Stop ringing the AI!!
/obj/machinery/holopad/proc/hangup_all_calls()
	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		HC.Disconnect(src)

/obj/machinery/holopad/Topic(href, href_list)
	if(..() || isAI(usr))
		return
	add_fingerprint(usr)
	if(!is_operational())
		return
	if (href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI in GLOB.silicon_mobs)
				if(!AI.client)
					continue
				to_chat(AI, "<span class='info'>Your presence is requested at <a href='?src=\ref[AI];jumptoholopad=\ref[src]'>\the [area]</a>.</span>")
		else
			temp = "A request for AI presence was already sent recently.<BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return

		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)

			var/result = input(usr, "Choose an area to call", "Holocall") as null|anything in callnames
			if(QDELETED(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				new /datum/holocall(usr, src, callnames[result])

	else if(href_list["connectcall"])
		var/datum/holocall/call_to_connect = locate(href_list["connectcall"])
		if(!QDELETED(call_to_connect))
			call_to_connect.Answer(src)
		temp = ""

	else if(href_list["disconnectcall"])
		var/datum/holocall/call_to_disconnect = locate(href_list["disconnectcall"])
		if(!QDELETED(call_to_disconnect))
			call_to_disconnect.Disconnect(src)
		temp = ""

	else if(href_list["mainmenu"])
		temp = ""
		if(outgoing_call)
			outgoing_call.Disconnect()

	updateDialog()

//do not allow AIs to answer calls or people will use it to meta the AI sattelite
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
	for(var/I in masters)
		var/mob/living/master = I
		var/mob/living/silicon/ai/AI = master
		if(!istype(AI))
			AI = null

		if(!QDELETED(master) && !master.incapacitated() && master.client && (!AI || AI.eyeobj))//If there is an AI attached, it's not incapacitated, it has a client, and the client eye is centered on the projector.
			if(is_operational())//If the  machine has power.
				if(AI)	//ais are range based
					if(get_dist(AI.eyeobj, src) <= holo_range)
						continue
					else
						var/obj/machinery/holopad/pad_close = get_closest_atom(/obj/machinery/holopad, holopads, AI.eyeobj)
						if(get_dist(pad_close, AI.eyeobj) <= holo_range)
							var/obj/effect/overlay/holo_pad_hologram/h = masters[master]
							unset_holo(master)
							pad_close.set_holo(master, h)
							continue
				else
					continue
		clear_holo(master)//If not, we want to get rid of the hologram.

	if(outgoing_call)
		outgoing_call.Check()

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad != src)
			if(force_answer_call && world.time > (HC.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2)))
				HC.Answer(src)
				break
			if(outgoing_call)
				HC.Disconnect(src)//can't answer calls while calling
			else
				playsound(src, 'sound/machines/twobeep.ogg', 100)	//bring, bring!

/obj/machinery/holopad/proc/activate_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		AI = null

	if(is_operational() && (!AI || AI.eyeobj.loc == loc))//If the projector has power and client eye is on it
		if (AI && istype(AI.current, /obj/machinery/holopad))
			to_chat(user, "<span class='danger'>ERROR:</span> \black Image feed in progress.")
			return

		var/obj/effect/overlay/holo_pad_hologram/Hologram = new(loc)//Spawn a blank effect at the location.
		if(AI)
			Hologram.icon = AI.holo_icon
		else	//make it like real life
			Hologram.icon = user.icon
			Hologram.icon_state = user.icon_state
			Hologram.copy_overlays(user, TRUE)
			//codersprite some holo effects here
			Hologram.alpha = 100
			Hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
			Hologram.Impersonation = user

		Hologram.copy_known_languages_from(user,replace = TRUE)
		Hologram.mouse_opacity = 0//So you can't click on it.
		Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		Hologram.anchored = 1//So space wind cannot drag it.
		Hologram.name = "[user.name] (Hologram)"//If someone decides to right click.
		Hologram.set_light(2)	//hologram lighting

		set_holo(user, Hologram)
		visible_message("<span class='notice'>A holographic image of [user] flickers to life before your eyes!</span>")

		return Hologram
	else
		to_chat(user, "<span class='danger'>ERROR:</span> Unable to project hologram.")

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/holopad/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	if(speaker && masters.len && !radio_freq)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(masters[master] && speaker != master)
				master.relay_speech(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad == src && speaker != HC.hologram)
			HC.user.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

	if(outgoing_call && speaker == outgoing_call.user)
		outgoing_call.hologram.say(raw_message)

/obj/machinery/holopad/proc/SetLightsAndPower()
	var/total_users = masters.len + LAZYLEN(holo_calls)
	use_power = total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE
	active_power_usage = HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users)
	if(total_users)
		set_light(2)
		icon_state = "holopad1"
	else
		set_light(0)
		icon_state = "holopad0"

/obj/machinery/holopad/proc/set_holo(mob/living/user, var/obj/effect/overlay/holo_pad_hologram/h)
	masters[user] = h
	var/mob/living/silicon/ai/AI = user
	if(istype(AI))
		AI.current = src
	SetLightsAndPower()
	return TRUE

/obj/machinery/holopad/proc/clear_holo(mob/living/user)
	qdel(masters[user]) // Get rid of user's hologram
	unset_holo(user)
	return TRUE

/obj/machinery/holopad/proc/unset_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI) && AI.current == src)
		AI.current = null
	masters -= user // Discard AI from the list of those who use holopad
	SetLightsAndPower()
	return TRUE

/obj/machinery/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(masters[user])
		var/obj/effect/overlay/holo_pad_hologram/H = masters[user]
		step_to(H, new_turf)
		H.loc = new_turf
		var/area/holo_area = get_area(src)
		var/area/eye_area = new_turf.loc

		if(!(eye_area in holo_area.related))
			clear_holo(user)
	return TRUE

/obj/effect/overlay/holo_pad_hologram
	var/mob/living/Impersonation
	var/datum/holocall/HC

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(HC)
		HC.Disconnect(HC.calling_holopad)
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
	return 1

/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()

/obj/item/weapon/circuitboard/machine/holopad
	name = "AI Holopad (Machine Board)"
	build_path = /obj/machinery/holopad
	origin_tech = "programming=1"
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
