/obj/machinery/computer/launchpad
	name = "\improper Launchpad Control Console"
	desc = "Used to teleport objects to and from a launchpad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/launchpad_console
	var/sending = 1
	var/current_pad //current pad viewed on the screen
	var/list/obj/machinery/launchpad/launchpads
	var/maximum_pads = 4

/obj/machinery/computer/launchpad/Initialize()
	launchpads = list()
	. = ..()

/obj/machinery/computer/launchpad/attack_paw(mob/user)
	to_chat(user, "<span class='warning'>You are too primitive to use this computer!</span>")
	return

/obj/machinery/computer/launchpad/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/launchpad))
			if(LAZYLEN(launchpads) < maximum_pads)
				launchpads |= M.buffer
				M.buffer = null
				to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot handle any more connections!</span>")
	else
		return ..()

/obj/machinery/computer/launchpad/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/launchpad/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/launchpad/proc/pad_exists(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	if(QDELETED(pad))
		return FALSE
	return TRUE

/obj/machinery/computer/launchpad/proc/get_pad(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	return pad

/obj/machinery/computer/launchpad/interact(mob/user)
	var/t
	if(!LAZYLEN(launchpads))
		in_use = FALSE     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No launchpad located.</div><BR>"
	else
		for(var/i=1, i<=LAZYLEN(launchpads), i++)
			if(pad_exists(i))
				var/obj/machinery/launchpad/pad = get_pad(i)
				if(pad.stat & NOPOWER)
					t+= "<span class='linkOff'>[pad.display_name]</span>"
				else
					t+= "<A href='?src=\ref[src];choose_pad=1;pad=[i]'>[pad.display_name]</A>"
			else
				launchpads -= get_pad(i)
		t += "<BR>"

		if(current_pad)
			var/obj/machinery/launchpad/pad = get_pad(current_pad)
			t += "<div class='statusDisplay'><b>[pad.display_name]</b></div>"
			t += "<A href='?src=\ref[src];change_name=1;pad=[current_pad]'>Rename</A>"
			t += "<A href='?src=\ref[src];remove=1;pad=[current_pad]'>Remove</A><BR><BR>"
			t += "  <A href='?src=\ref[src];raisey=1;pad=[current_pad]'>^</A><BR>"
			t += "<A href='?src=\ref[src];lowerx=1;pad=[current_pad]'><</A>"
			t += "<A href='?src=\ref[src];raisex=1;pad=[current_pad]'>></A><BR>"
			t += "  <A href='?src=\ref[src];lowery=1;pad=[current_pad]'>v</A><BR>"
			t += "<BR>"
			t += "<div class='statusDisplay'>Current offset:</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.y_offset)] [pad.y_offset > 0 ? "N":"S"]</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.x_offset)] [pad.x_offset > 0 ? "E":"W"]</div><BR>"

			t += "<BR><A href='?src=\ref[src];launch=1;pad=[current_pad]'>Launch</A>"
			t += " <A href='?src=\ref[src];pull=1;pad=[current_pad]'>Pull</A>"

	var/datum/browser/popup = new(user, "launchpad", name, 300, 500)
	popup.set_content(t)
	popup.open()

/obj/machinery/computer/launchpad/proc/doteleport(mob/user, obj/machinery/launchpad/pad)
	if(pad.teleporting)
		to_chat(user, "<span class='warning'>ERROR: Launchpad busy.</span>")
		return



	if(pad)
		var/target_x = pad.x + pad.x_offset
		var/target_y = pad.y + pad.y_offset
		var/turf/target = locate(target_x, target_y, pad.z)
		var/area/A = get_area(target)

		flick("pad-beam", pad)
		playsound(get_turf(pad), 'sound/weapons/flash.ogg', 25, 1)
		pad.teleporting = TRUE


		sleep(pad.teleport_speed)

		if(QDELETED(pad) || !pad.isAvailable())
			return

		pad.teleporting = FALSE

		// use a lot of power
		use_power(1000)

		var/turf/source = target
		var/turf/dest = get_turf(pad)
		var/log_msg = ""
		log_msg += ": [key_name(user)] has teleported "

		if(sending)
			source = dest
			dest = target

		flick("pad-beam", pad)
		playsound(get_turf(pad), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
		for(var/atom/movable/ROI in source)
			// if is anchored, don't let through
			if(ROI.anchored)
				if(isliving(ROI))
					var/mob/living/L = ROI
					if(L.buckled)
						// TP people on office chairs
						if(L.buckled.anchored)
							continue

						log_msg += "[key_name(L)] (on a chair), "
					else
						continue
				else if(!isobserver(ROI))
					continue
			if(ismob(ROI))
				var/mob/T = ROI
				log_msg += "[key_name(T)], "
			else
				log_msg += "[ROI.name]"
				if (istype(ROI, /obj/structure/closet))
					var/obj/structure/closet/C = ROI
					log_msg += " ("
					for(var/atom/movable/Q as mob|obj in C)
						if(ismob(Q))
							log_msg += "[key_name(Q)], "
						else
							log_msg += "[Q.name], "
					if (dd_hassuffix(log_msg, "("))
						log_msg += "empty)"
					else
						log_msg = dd_limittext(log_msg, length(log_msg) - 2)
						log_msg += ")"
				log_msg += ", "
			do_teleport(ROI, dest)

		if (dd_hassuffix(log_msg, ", "))
			log_msg = dd_limittext(log_msg, length(log_msg) - 2)
		else
			log_msg += "nothing"
		log_msg += " [sending ? "to" : "from"] [target_x], [target_y], [pad.z] ([A ? A.name : "null area"])"
		investigate_log(log_msg, "telesci")
		updateDialog()

/obj/machinery/computer/launchpad/proc/teleport(mob/user, obj/machinery/launchpad/pad)
	if(QDELETED(pad))
		to_chat(user, "<span class='warning'>ERROR: Launchpad not responding. Check launchpad integrity.</span>")
		return
	if(!pad.isAvailable())
		to_chat(user, "<span class='warning'>ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>")
		return
	doteleport(user, pad)

/obj/machinery/computer/launchpad/Topic(href, href_list)
	var/obj/machinery/launchpad/pad
	if(href_list["pad"])
		pad = get_pad(text2num(href_list["pad"]))

	if(..())
		return
	if(!LAZYLEN(launchpads))
		updateDialog()
		return

	if(href_list["choose_pad"])
		current_pad = text2num(href_list["pad"])

	if(href_list["raisex"])
		if(pad.x_offset < pad.range)
			pad.x_offset++

	if(href_list["lowerx"])
		if(pad.x_offset > (pad.range * -1))
			pad.x_offset--

	if(href_list["raisey"])
		if(pad.y_offset < pad.range)
			pad.y_offset++

	if(href_list["lowery"])
		if(pad.y_offset > (pad.range * -1))
			pad.y_offset--

	if(href_list["change_name"])
		var/new_name = stripped_input(usr, "How do you want to rename the launchpad?", "Launchpad", pad.display_name, 15) as text|null
		if(!new_name)
			return
		pad.display_name = new_name

	if(href_list["remove"])
		if(usr && alert(usr, "Are you sure?", "Remove Launchpad", "I'm Sure", "Abort") != "Abort")
			launchpads -= pad

	if(href_list["launch"])
		sending = TRUE
		teleport(usr, pad)

	if(href_list["pull"])
		sending = FALSE
		teleport(usr, pad)

	updateDialog()