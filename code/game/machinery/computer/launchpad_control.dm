/obj/machinery/computer/launchpad
	name = "\improper launchpad control console"
	desc = "Used to teleport objects to and from a launchpad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/launchpad_console
<<<<<<< HEAD
	var/screen = "select" //current UI view
	var/obj/machinery/launchpad/current_pad //current pad viewed on the screen
=======
	var/sending = TRUE
	var/current_pad //current pad viewed on the screen
>>>>>>> Updated this old code to fork
	var/list/obj/machinery/launchpad/launchpads
	var/maximum_pads = 4

/obj/machinery/computer/launchpad/Initialize()
	launchpads = list()
	. = ..()

/obj/machinery/computer/launchpad/attack_paw(mob/user)
	to_chat(user, "<span class='warning'>You are too primitive to use this computer!</span>")
	return

/obj/machinery/computer/launchpad/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/launchpad))
			if(LAZYLEN(launchpads) < maximum_pads)
				launchpads |= M.buffer
				M.buffer = null
				to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot handle any more connections!</span>")
	else
		return ..()

/obj/machinery/computer/launchpad/proc/pad_exists(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	if(QDELETED(pad))
		return FALSE
	return TRUE

<<<<<<< HEAD
/obj/machinery/computer/launchpad/proc/teleport(mob/user, obj/machinery/launchpad/pad, sending)
	if(QDELETED(pad))
		to_chat(user, "<span class='warning'>ERROR: Launchpad not responding. Check launchpad integrity.</span>")
		return
	if(!pad.isAvailable())
		to_chat(user, "<span class='warning'>ERROR: Launchpad not operative. Make sure the launchpad is ready and powered.</span>")
		return
	pad.doteleport(user, sending)

=======
>>>>>>> Updated this old code to fork
/obj/machinery/computer/launchpad/proc/get_pad(number)
	var/obj/machinery/launchpad/pad = launchpads[number]
	return pad

<<<<<<< HEAD
/obj/machinery/computer/launchpad/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "launchpad_console", name, 350, 470, master_ui, state)
		ui.open()

/obj/machinery/computer/launchpad/ui_data(mob/user)
	var/list/data = list()
	if(!LAZYLEN(launchpads))
		data["screen"] = "empty"
		return data
	else
		data["screen"] = screen

	if(screen == "select")
		var/list/pad_list = list()
		for(var/i in 1 to LAZYLEN(launchpads))
			if(pad_exists(i))
				var/obj/machinery/launchpad/pad = get_pad(i)
				var/list/this_pad = list()
				this_pad["name"] = pad.display_name
				this_pad["id"] = i
				if(pad.stat & NOPOWER)
					this_pad["inactive"] = TRUE
				pad_list += list(this_pad)
			else
				launchpads -= get_pad(i)
		data["launchpads"] = pad_list
	else if(screen == "control")
		if(QDELETED(current_pad) || (current_pad.stat & NOPOWER))
			data["pad_active"] = FALSE
			return data
		data["pad_active"] = TRUE
		data["pad_name"] = current_pad.display_name
		data["abs_x"] = abs(current_pad.x_offset)
		data["abs_y"] = abs(current_pad.y_offset)
		data["north_south"] = current_pad.y_offset > 0 ? "N":"S"
		data["east_west"] = current_pad.x_offset > 0 ? "E":"W"

	return data

/obj/machinery/computer/launchpad/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("return")
			screen = "select"
			. = TRUE
		if("select_pad")
			current_pad = get_pad(text2num(params["id"]))
			screen = "control"
			. = TRUE
		if("right")
			if(!current_pad.teleporting)
				if(current_pad.x_offset < current_pad.range)
					current_pad.x_offset++
					current_pad.update_indicator()
			. = TRUE

		if("left")
			if(!current_pad.teleporting)
				if(current_pad.x_offset > (current_pad.range * -1))
					current_pad.x_offset--
					current_pad.update_indicator()
			. = TRUE

		if("up")
			if(!current_pad.teleporting)
				if(current_pad.y_offset < current_pad.range)
					current_pad.y_offset++
					current_pad.update_indicator()
			. = TRUE

		if("down")
			if(!current_pad.teleporting)
				if(current_pad.y_offset > (current_pad.range * -1))
					current_pad.y_offset--
					current_pad.update_indicator()
			. = TRUE

		if("up-right")
			if(!current_pad.teleporting)
				if(current_pad.y_offset < current_pad.range)
					current_pad.y_offset++
				if(current_pad.x_offset < current_pad.range)
					current_pad.x_offset++
				current_pad.update_indicator()
			. = TRUE

		if("up-left")
			if(!current_pad.teleporting)
				if(current_pad.y_offset < current_pad.range)
					current_pad.y_offset++
				if(current_pad.x_offset > (current_pad.range * -1))
					current_pad.x_offset--
				current_pad.update_indicator()
			. = TRUE

		if("down-right")
			if(!current_pad.teleporting)
				if(current_pad.y_offset > (current_pad.range * -1))
					current_pad.y_offset--
				if(current_pad.x_offset < current_pad.range)
					current_pad.x_offset++
				current_pad.update_indicator()
			. = TRUE

		if("down-left")
			if(!current_pad.teleporting)
				if(current_pad.y_offset > (current_pad.range * -1))
					current_pad.y_offset--
				if(current_pad.x_offset > (current_pad.range * -1))
					current_pad.x_offset--
				current_pad.update_indicator()
			. = TRUE

		if("reset")
			if(!current_pad.teleporting)
				current_pad.y_offset = 0
				current_pad.x_offset = 0
				current_pad.update_indicator()
			. = TRUE

		if("manual_x")
			if(!current_pad.teleporting)
				var/new_x = input("Set the X offset (Horizontal)","X Offset", current_pad.x_offset) as null|num
				if(!isnull(new_x))
					new_x = CLAMP(new_x, current_pad.range * -1, current_pad.range)
				. = TRUE
				current_pad.x_offset = new_x
				current_pad.update_indicator()
			. = TRUE

		if("manual_y")
			if(!current_pad.teleporting)
				var/new_y = input("Set the Y offset (Vertical)","Y Offset", current_pad.y_offset) as null|num
				if(!isnull(new_y))
					new_y = CLAMP(new_y, current_pad.range * -1, current_pad.range)
				. = TRUE
				current_pad.y_offset = new_y
				current_pad.update_indicator()
			. = TRUE

		if("rename")
			. = TRUE
			var/new_name = stripped_input(usr, "How do you want to rename the launchpad?", "Launchpad", current_pad.display_name, 15)
			if(!new_name)
				return
			current_pad.display_name = new_name

		if("remove")
			. = TRUE
			if(usr && alert(usr, "Are you sure?", "Unlink Launchpad", "I'm Sure", "Abort") != "Abort")
				launchpads -= current_pad
				current_pad = null

		if("launch")
			teleport(usr, current_pad, TRUE)
			. = TRUE

		if("pull")
			teleport(usr, current_pad, FALSE)
			. = TRUE
	. = TRUE
=======
/obj/machinery/computer/launchpad/ui_interact(mob/user)
	. = ..()
	var/list/t = list()
	if(!LAZYLEN(launchpads))
		obj_flags &= ~IN_USE     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No launchpad located.</div><BR>"
	else
		for(var/i in 1 to LAZYLEN(launchpads))
			if(pad_exists(i))
				var/obj/machinery/launchpad/pad = get_pad(i)
				if(pad.stat & NOPOWER)
					t+= "<span class='linkOff'>[pad.display_name]</span>"
				else
					t+= "<A href='?src=[REF(src)];choose_pad=1;pad=[i]'>[pad.display_name]</A>"
			else
				launchpads -= get_pad(i)
		t += "<BR>"

		if(current_pad)
			var/obj/machinery/launchpad/pad = get_pad(current_pad)
			t += "<div class='statusDisplay'><b>[pad.display_name]</b></div>"
			t += "<A href='?src=[REF(src)];change_name=1;pad=[current_pad]'>Rename</A>"
			t += "<A href='?src=[REF(src)];remove=1;pad=[current_pad]'>Remove</A><BR><BR>"
			t += "<A href='?src=[REF(src)];raisey=1;lowerx=1;pad=[current_pad]'>O</A>" //up-left
			t += "<A href='?src=[REF(src)];raisey=1;pad=[current_pad]'>^</A>" //up
			t += "<A href='?src=[REF(src)];raisey=1;raisex=1;pad=[current_pad]'>O</A><BR>" //up-right
			t += "<A href='?src=[REF(src)];lowerx=1;pad=[current_pad]'><</A>"//left
			t += "<A href='?src=[REF(src)];reset=1;pad=[current_pad]'>R</A>"//reset to 0
			t += "<A href='?src=[REF(src)];raisex=1;pad=[current_pad]'>></A><BR>"//right
			t += "<A href='?src=[REF(src)];lowery=1;lowerx=1;pad=[current_pad]'>O</A>"//down-left
			t += "<A href='?src=[REF(src)];lowery=1;pad=[current_pad]'>v</A>"//down
			t += "<A href='?src=[REF(src)];lowery=1;raisex=1;pad=[current_pad]'>O</A><BR>"//down-right
			t += "<BR>"
			t += "<div class='statusDisplay'>Current offset:</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.y_offset)] [pad.y_offset > 0 ? "N":"S"]</div><BR>"
			t += "<div class='statusDisplay'>[abs(pad.x_offset)] [pad.x_offset > 0 ? "E":"W"]</div><BR>"

			t += "<BR><A href='?src=[REF(src)];launch=1;pad=[current_pad]'>Launch</A>"
			t += " <A href='?src=[REF(src)];pull=1;pad=[current_pad]'>Pull</A>"

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
		var/new_name = stripped_input(usr, "What do you wish to name the launchpad?", "Launchpad", pad.display_name, 15)
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
>>>>>>> Updated this old code to fork
