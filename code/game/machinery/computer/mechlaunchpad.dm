/obj/machinery/computer/mechpad
	name = "orbital mech pad console"
	desc = "A computer designed to handle the calculations and routing required for sending and receiving mechs from orbit. Requires a link to a nearby Orbital Mech Pad to function."
	icon_screen = "mechpad"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/mechpad
	///ID of the mechpad, used for linking up
	var/id = "roboticsmining"
	///Selected mechpad in the console
	var/selected_id
	///Mechpads that it can send mechs through to other mechpads
	var/obj/machinery/mechpad/connected_mechpad
	///List of mechpads connected
	var/list/obj/machinery/mechpad/mechpads = list()
	///Maximum amount of pads connected at once
	var/maximum_pads = 3

/obj/machinery/computer/mechpad/Initialize(mapload)
	. = ..()
	if(mapload)
		connected_mechpad = connect_to_pad()
		connected_mechpad.connected_console = src
		connected_mechpad.id = id
		return INITIALIZE_HINT_LATELOAD
	else
		id ="handmade"

/obj/machinery/computer/mechpad/LateInitialize()
	for(var/obj/machinery/mechpad/pad in GLOB.mechpad_list)
		if(pad == connected_mechpad)
			continue
		if(pad.id != id)
			continue
		mechpads += pad
		LAZYADD(pad.consoles, src)
		if(mechpads.len > maximum_pads)
			break

/obj/machinery/computer/mechpad/Destroy()
	if(connected_mechpad)
		connected_mechpad.connected_console = null
		connected_mechpad = null
	for(var/obj/machinery/mechpad/mechpad in mechpads)
		LAZYREMOVE(mechpad.consoles, src)
	return ..()

///Tries to locate a pad in the cardinal directions, if it finds one it returns it
/obj/machinery/computer/mechpad/proc/connect_to_pad()
	if(connected_mechpad)
		return
	for(var/direction in GLOB.cardinals)
		connected_mechpad = locate(/obj/machinery/mechpad, get_step(src, direction))
		if(connected_mechpad)
			break
	return connected_mechpad

/obj/machinery/computer/mechpad/multitool_act(mob/living/user, obj/item/tool)
	if(!multitool_check_buffer(user, tool))
		return
	var/obj/item/multitool/multitool = tool
	if(istype(multitool.buffer, /obj/machinery/mechpad))
		var/obj/machinery/mechpad/buffered_console = multitool.buffer
		if(!(mechpads.len < maximum_pads))
			to_chat(user, span_warning("[src] cannot handle any more connections!"))
			return
		if(buffered_console == connected_mechpad)
			to_chat(user, span_warning("[src] cannot connect to its own mechpad!"))
		else if(!connected_mechpad && buffered_console == connect_to_pad())
			connected_mechpad = buffered_console
			connected_mechpad.connected_console = src
			connected_mechpad.id = id
			multitool.buffer = null
			to_chat(user, span_notice("You connect the console to the pad with data from the [multitool.name]'s buffer."))
		else
			mechpads += buffered_console
			LAZYADD(buffered_console.consoles, src)
			multitool.buffer = null
			to_chat(user, span_notice("You upload the data from the [multitool.name]'s buffer."))

/**
 * Tries to call the launch proc on the connected mechpad, returns if there is no connected mechpad or there is no mecha on the pad
 * Arguments:
 * * user - The user of the proc
 * * where - The mechpad that the connected mechpad will try to send a supply pod to
 */
/obj/machinery/computer/mechpad/proc/try_launch(mob/user, obj/machinery/mechpad/where)
	if(!connected_mechpad)
		to_chat(user, span_warning("[src] has no connected pad!"))
		return
	if(connected_mechpad.panel_open)
		to_chat(user, span_warning("[src]'s pad has its' panel open! It won't work!"))
		return
	if(!(locate(/obj/vehicle/sealed/mecha) in get_turf(connected_mechpad)))
		to_chat(user, span_warning("[src] detects no mecha on the pad!"))
		return
	connected_mechpad.launch(where)

///Checks if the pad of a certain number has been QDELETED, if yes returns FALSE, otherwise returns TRUE
/obj/machinery/computer/mechpad/proc/pad_exists(number)
	var/obj/machinery/mechpad/pad = mechpads[number]
	if(QDELETED(pad))
		return FALSE
	return TRUE

///Returns the pad of the value specified
/obj/machinery/computer/mechpad/proc/get_pad(number)
	var/obj/machinery/mechpad/pad = mechpads[number]
	return pad

/obj/machinery/computer/mechpad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechpadConsole", name)
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
	data["connected_mechpad"] = !!connected_mechpad
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
	. = ..()
	if(.)
		return
	var/obj/machinery/mechpad/current_pad = mechpads[selected_id]
	switch(action)
		if("select_pad")
			selected_id = text2num(params["id"])
		if("rename")
			var/new_name = params["name"]
			if(!new_name)
				return
			current_pad.display_name = new_name
		if("remove")
			if(usr && tgui_alert(usr, "Are you sure?", "Unlink Orbital Pad", list("I'm Sure", "Abort")) == "I'm Sure")
				mechpads -= current_pad
				LAZYREMOVE(current_pad.consoles, src)
				selected_id = null
		if("launch")
			try_launch(usr, current_pad)
	. = TRUE
