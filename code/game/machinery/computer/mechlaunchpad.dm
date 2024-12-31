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
		connect_launchpad(find_pad())
		return INITIALIZE_HINT_LATELOAD
	else
		id = "handmade[REF(src)]"

/obj/machinery/computer/mechpad/proc/connect_launchpad(obj/machinery/mechpad/pad)
	if(connected_mechpad)
		return
	connected_mechpad = pad
	connected_mechpad.id = id
	RegisterSignal(connected_mechpad, COMSIG_QDELETING, PROC_REF(unconnect_launchpad))

/obj/machinery/computer/mechpad/proc/unconnect_launchpad(obj/machinery/mechpad/pad)
	SIGNAL_HANDLER
	connected_mechpad = null

/obj/machinery/computer/mechpad/post_machine_initialize()
	. = ..()
	for(var/obj/machinery/mechpad/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/mechpad))
		if(pad == connected_mechpad)
			continue
		if(pad.id != id)
			continue
		add_pad(pad)
		if(mechpads.len > maximum_pads)
			break

#define MECH_LAUNCH_TIME (5 SECONDS)

/obj/machinery/computer/mechpad/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(user.combat_mode || machine_stat & (NOPOWER|BROKEN) || DOING_INTERACTION_WITH_TARGET(user, src))
		return ..()
	var/mech_dir = mecha_attacker.dir
	balloon_alert(user, "carefully starting launch process...")
	INVOKE_ASYNC(src, PROC_REF(random_beeps), user, MECH_LAUNCH_TIME, 0.5 SECONDS, 1.5 SECONDS)
	if(!do_after(user, MECH_LAUNCH_TIME, src, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), mecha_attacker, mech_dir)))
		balloon_alert(user, "interrupted!")
		return
	var/obj/machinery/mechpad/current_pad = mechpads[selected_id]
	try_launch(user, current_pad)

#undef MECH_LAUNCH_TIME

/obj/machinery/computer/mechpad/proc/do_after_checks(obj/vehicle/sealed/mecha/mech, mech_dir)
	return mech.dir == mech_dir && !(machine_stat & (NOPOWER|BROKEN))

/// A proc that makes random beeping sounds for a set amount of time, the sounds are separated by a random amount of time.
/obj/machinery/computer/mechpad/proc/random_beeps(mob/user, time = 0, mintime = 0, maxtime = 1)
	var/static/list/beep_sounds = list('sound/machines/terminal/terminal_prompt_confirm.ogg', 'sound/machines/terminal/terminal_prompt_deny.ogg', 'sound/machines/terminal/terminal_error.ogg', 'sound/machines/terminal/terminal_select.ogg', 'sound/machines/terminal/terminal_success.ogg')
	var/time_to_spend = 0
	var/orig_time = time
	while(time > 0)
		if(!DOING_INTERACTION_WITH_TARGET(user, src) && time != orig_time)
			return
		time_to_spend = rand(mintime, maxtime)
		playsound(src, pick(beep_sounds), 75)
		time -= time_to_spend
		stoplag(time_to_spend)

///Tries to locate a pad in the cardinal directions, if it finds one it returns it
/obj/machinery/computer/mechpad/proc/find_pad()
	var/found_mechpad
	for(var/direction in GLOB.cardinals)
		found_mechpad = locate(/obj/machinery/mechpad, get_step(src, direction))
		if(!found_mechpad)
			continue
		return found_mechpad

/obj/machinery/computer/mechpad/multitool_act(mob/living/user, obj/item/multitool/multitool)
	. = NONE
	if(!istype(multitool.buffer, /obj/machinery/mechpad))
		return

	var/obj/machinery/mechpad/buffered_pad = multitool.buffer
	if(!(mechpads.len < maximum_pads))
		to_chat(user, span_warning("[src] cannot handle any more connections!"))
		return ITEM_INTERACT_SUCCESS

	if(buffered_pad == connected_mechpad)
		to_chat(user, span_warning("[src] cannot connect to its own mechpad!"))
		return ITEM_INTERACT_BLOCKING

	if(!connected_mechpad && buffered_pad == find_pad())
		if(buffered_pad in mechpads)
			remove_pad(buffered_pad)
		connect_launchpad(buffered_pad)
		multitool.set_buffer(null)
		to_chat(user, span_notice("You connect the console to the pad with data from the [multitool.name]'s buffer."))
		return ITEM_INTERACT_SUCCESS

	add_pad(buffered_pad)
	multitool.set_buffer(null)
	to_chat(user, span_notice("You upload the data from the [multitool.name]'s buffer."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/mechpad/proc/add_pad(obj/machinery/mechpad/pad)
	mechpads += pad
	RegisterSignal(pad, COMSIG_QDELETING, PROC_REF(remove_pad))

/obj/machinery/computer/mechpad/proc/remove_pad(obj/machinery/mechpad/pad)
	SIGNAL_HANDLER
	mechpads -= pad
	UnregisterSignal(pad, COMSIG_QDELETING)

/**
 * Tries to call the launch proc on the connected mechpad, returns if unavailable
 * Arguments:
 * * user - The user of the proc
 * * where - The mechpad that the connected mechpad will try to send a supply pod to
 */
/obj/machinery/computer/mechpad/proc/try_launch(mob/user, obj/machinery/mechpad/where)
	if(!can_launch(user, where))
		return
	flick("mechpad-launch", connected_mechpad)
	playsound(connected_mechpad, 'sound/machines/beep/triple_beep.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(start_launch), user, where), 1 SECONDS)

/obj/machinery/computer/mechpad/proc/start_launch(mob/user, obj/machinery/mechpad/where)
	if(!can_launch(user, where, silent = TRUE))
		return
	var/obj/vehicle/sealed/mecha/mech = locate() in get_turf(connected_mechpad)
	mech.setDir(SOUTH)
	connected_mechpad.launch(where)

/obj/machinery/computer/mechpad/proc/can_launch(mob/user, obj/machinery/mechpad/where, silent = FALSE)
	if(QDELETED(where))
		if(!silent)
			to_chat(user, span_warning("No destination!"))
		return FALSE
	if(!connected_mechpad)
		if(!silent)
			to_chat(user, span_warning("[src] has no connected pad!"))
		return FALSE
	if(connected_mechpad.machine_stat & (BROKEN|NOPOWER) || where.machine_stat & (BROKEN|NOPOWER))
		if(!silent)
			to_chat(user, span_warning("Pads are nonfunctional!"))
		return FALSE
	if(connected_mechpad.panel_open || where.panel_open)
		if(!silent)
			to_chat(user, span_warning("Pads have open panels!"))
		return FALSE
	var/obj/vehicle/sealed/mecha/mech = locate() in get_turf(connected_mechpad)
	if(!mech)
		if(!silent)
			to_chat(user, span_warning("[src] detects no mecha on the pad!"))
		return FALSE
	if(where.mech_only && (locate(/mob/living) in mech.get_all_contents()))
		if(!silent)
			to_chat(user, span_warning("The target pad does not allow lifeforms!"))
		return FALSE
	return TRUE


///Returns the pad of the value specified
/obj/machinery/computer/mechpad/proc/get_pad(number)
	var/obj/machinery/mechpad/pad = mechpads[number]
	return pad

/obj/machinery/computer/mechpad/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechpadConsole", name)
		ui.open()

/obj/machinery/computer/mechpad/ui_data(mob/user)
	var/list/data = list()
	var/list/pad_list = list()
	for(var/i in 1 to length(mechpads))
		var/obj/machinery/mechpad/pad = get_pad(i)
		var/list/this_pad = list()
		this_pad["name"] = pad.display_name
		this_pad["id"] = i
		pad_list += list(this_pad)
	data["mechpads"] = pad_list
	data["selected_id"] = selected_id
	data["connected_mechpad"] = !!connected_mechpad && !(connected_mechpad.machine_stat & (BROKEN|NOPOWER))
	if(selected_id)
		var/obj/machinery/mechpad/current_pad = mechpads[selected_id]
		if(!current_pad)
			selected_id = null
		else
			data["pad_name"] = current_pad.display_name
			data["pad_active"] = !!current_pad && !(current_pad.machine_stat & (BROKEN|NOPOWER))
			data["mechonly"] = current_pad.mech_only
	return data

/obj/machinery/computer/mechpad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
				remove_pad(current_pad)
				selected_id = null
		if("launch")
			try_launch(usr, current_pad)
	. = TRUE
