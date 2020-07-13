/obj/machinery/computer/mechpad
	name = "mecha orbital pad console"
	desc = "Sends mechs through space to space. Why would you do that?"
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	ui_x = 475
	ui_y = 260

	var/selected_id
	var/obj/machinery/mechpad/connected_mechpad
	var/list/obj/machinery/mechpad/mechpads = list()
	var/maximum_pads = 3

/obj/machinery/computer/mechpad/Initialize(mapload)
	. = ..()
	if(mapload)
		connected_mechpad = connect_to_pad()
		connected_mechpad.connected_console = src
		for(var/obj/machinery/mechpad/pad in world)
			if(pad == connected_mechpad)
				continue
			mechpads |= pad
			if(LAZYLEN(mechpads) < maximum_pads)
				break

/obj/machinery/computer/mechpad/Destroy()
	connected_mechpad.connected_console = null
	return ..()

/obj/machinery/computer/mechpad/proc/connect_to_pad()
	if(connected_mechpad)
		return
	for(var/direction in GLOB.cardinals)
		connected_mechpad = locate(/obj/machinery/mechpad, get_step(src, direction))
		if(connected_mechpad)
			break
	return connected_mechpad

/obj/machinery/computer/mechpad/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/mechpad))
			if(LAZYLEN(mechpads) < maximum_pads)
				if(M.buffer == connected_mechpad)
					to_chat(user, "<span class='warning'>[src] cannot connect to its own mechpad!</span>")
				else if(!connected_mechpad && M.buffer == connect_to_pad())
					connected_mechpad = connect_to_pad()
					M.buffer = null
					to_chat(user, "<span class='notice'>You connect the console to the pad with data from the [W.name]'s buffer.</span>")
				else
					mechpads |= M.buffer
					M.buffer = null
					to_chat(user, "<span class='notice'>You upload the data from the [W.name]'s buffer.</span>")
			else
				to_chat(user, "<span class='warning'>[src] cannot handle any more connections!</span>")
	else
		return ..()

/obj/machinery/computer/mechpad/proc/try_launch(var/obj/machinery/mechpad/where)
	if(!connected_mechpad)
		to_chat(user, "<span class='warning'>[src] has no connected pad!</span>")
		return
	if(locate(/obj/mecha) in get_turf(connected_mechpad))
		connected_mechpad.launch(where)
	else
		to_chat(user, "<span class='warning'>[src] detects no mecha on the pad!</span>")

/obj/machinery/computer/mechpad/proc/pad_exists(number)
	var/obj/machinery/mechpad/pad = mechpads[number]
	if(QDELETED(pad))
		return FALSE
	return TRUE

/obj/machinery/computer/mechpad/proc/get_pad(number)
	var/obj/machinery/mechpad/pad = mechpads[number]
	return pad

/obj/machinery/computer/mechpad/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MechpadConsole", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/mechpad/ui_data(mob/user)
	var/list/data = list()
	var/list/pad_list = list()
	for(var/i in 1 to LAZYLEN(mechpads))
		if(pad_exists(i))
			var/obj/machinery/mechpad/pad = get_pad(i)
			var/list/this_pad = list()
			this_pad["name"] = pad.display_name
			this_pad["id"] = i
			if(pad.machine_stat & NOPOWER)
				this_pad["inactive"] = TRUE
			pad_list += list(this_pad)
		else
			mechpads -= get_pad(i)
	data["mechpads"] = pad_list
	data["selected_id"] = selected_id
	data["connected_mechpad"] = connected_mechpad
	if(selected_id)
		var/obj/machinery/mechpad/current_pad = mechpads[selected_id]
		data["pad_name"] = current_pad.display_name
		data["selected_pad"] = current_pad
		if(QDELETED(current_pad) || (current_pad.machine_stat & NOPOWER))
			data["pad_active"] = FALSE
			return data
		data["pad_active"] = TRUE
	return data

/obj/machinery/computer/mechpad/ui_act(action, params)
	if(..())
		return
	var/obj/machinery/mechpad/current_pad = mechpads[selected_id]
	switch(action)
		if("select_pad")
			selected_id = text2num(params["id"])
			. = TRUE
		if("rename")
			. = TRUE
			var/new_name = params["name"]
			if(!new_name)
				return
			current_pad.display_name = new_name
		if("remove")
			if(usr && alert(usr, "Are you sure?", "Unlink Orbital Pad", "I'm Sure", "Abort") != "Abort")
				mechpads -= current_pad
				selected_id = null
			. = TRUE
		if("launch")
			try_launch(current_pad)
			. = TRUE
	. = TRUE
