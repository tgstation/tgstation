/obj/machinery/computer/launchpad
	name = "\improper Launchpad Control Console"
	desc = "Used to teleport objects to and from a launchpad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/weapon/circuitboard/computer/launchpad_console
	var/sending = TRUE
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
	var/list/t = list()
	if(!LAZYLEN(launchpads))
		in_use = FALSE     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No launchpad located.</div><BR>"
	else
		for(var/i in 1 to LAZYLEN(launchpads))
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
			t += "<A href='?src=\ref[src];raisey=1;lowerx=1;pad=[current_pad]'>O</A>" //up-left
			t += "<A href='?src=\ref[src];raisey=1;pad=[current_pad]'>^</A>" //up
			t += "<A href='?src=\ref[src];raisey=1;raisex=1;pad=[current_pad]'>O</A><BR>" //up-right
			t += "<A href='?src=\ref[src];lowerx=1;pad=[current_pad]'><</A>"//left
			t += "<A href='?src=\ref[src];reset=1;pad=[current_pad]'>R</A>"//reset to 0
			t += "<A href='?src=\ref[src];raisex=1;pad=[current_pad]'>></A><BR>"//right
			t += "<A href='?src=\ref[src];lowery=1;lowerx=1;pad=[current_pad]'>O</A>"//down-left
			t += "<A href='?src=\ref[src];lowery=1;pad=[current_pad]'>v</A>"//down
			t += "<A href='?src=\ref[src];lowery=1;raisex=1;pad=[current_pad]'>O</A><BR>"//down-right
			t += "<BR>"
			t += "<div class='statusDisplay'>Current offset:</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.y_offset)] [pad.y_offset > 0 ? "N":"S"]</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.x_offset)] [pad.x_offset > 0 ? "E":"W"]</div><BR>"

			t += "<BR><A href='?src=\ref[src];launch=1;pad=[current_pad]'>Launch</A>"
			t += " <A href='?src=\ref[src];pull=1;pad=[current_pad]'>Pull</A>"

	var/datum/browser/popup = new(user, "launchpad", name, 300, 500)
	popup.set_content(t.Join())
	popup.open()

/obj/machinery/computer/launchpad/proc/teleport(mob/user, obj/machinery/launchpad/pad)
	if(QDELETED(pad))
		to_chat(user, "<span class='warning'>ERROR: Launchpad not responding. Check launchpad integrity.</span>")
		return
	if(!pad.isAvailable())
		to_chat(user, "<span class='warning'>ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>")
		return
	pad.doteleport(user, sending)

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

	if(href_list["reset"])
		pad.y_offset = 0
		pad.x_offset = 0

	if(href_list["change_name"])
		var/new_name = stripped_input(usr, "What do you wish to name the launchpad?", "Launchpad", pad.display_name, 15) as text|null
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