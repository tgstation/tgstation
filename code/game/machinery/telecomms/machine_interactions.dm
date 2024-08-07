// This file is separate from telecommunications.dm to isolate the implementation
// of basic interactions with the machines.

/obj/machinery/telecomms
	/// The current temporary frequency used to add new filtered frequencies
	/// options.
	var/tempfreq = FREQ_COMMON
	/// Illegal frequencies that can't be listened to by telecommunication servers.
	var/list/banned_frequencies = list(
		FREQ_SYNDICATE,
		FREQ_CENTCOM,
		FREQ_CTF_RED,
		FREQ_CTF_YELLOW,
		FREQ_CTF_GREEN,
		FREQ_CTF_BLUE,
	)

/obj/machinery/telecomms/attackby(obj/item/attacking_item, mob/user, params)

	var/icon_closed = initial(icon_state)
	var/icon_open = "[initial(icon_state)]_o"
	if(!on)
		icon_closed = "[initial(icon_state)]_off"
		icon_open = "[initial(icon_state)]_o_off"

	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, attacking_item))
		return
	// Using a multitool lets you access the receiver's interface
	else if(attacking_item.tool_behaviour == TOOL_MULTITOOL)
		attack_hand(user)

	else if(default_deconstruction_crowbar(attacking_item))
		return
	else
		return ..()

/obj/machinery/telecomms/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telecomms")
		ui.open()

/obj/machinery/telecomms/ui_data(mob/user)
	var/list/data = list()

	data += add_option()

	data["minfreq"] = MIN_FREE_FREQ
	data["maxfreq"] = MAX_FREE_FREQ
	data["frequency"] = tempfreq

	var/obj/item/multitool/heldmultitool = get_multitool(user)
	data["multitool"] = heldmultitool

	if(heldmultitool)
		data["multibuff"] = heldmultitool.buffer

	data["toggled"] = toggled
	data["id"] = id
	data["network"] = network
	data["prefab"] = autolinkers.len ? TRUE : FALSE

	var/list/linked = list()
	var/i = 0
	data["linked"] = list()
	for(var/obj/machinery/telecomms/machine in links)
		i++
		if(machine.hide && !hide)
			continue
		var/list/entry = list()
		entry["index"] = i
		entry["name"] = machine.name
		entry["id"] = machine.id
		linked += list(entry)
	data["linked"] = linked

	var/list/frequencies = list()
	data["frequencies"] = list()
	for(var/x in freq_listening)
		frequencies += list(x)
	data["frequencies"] = frequencies

	return data

/obj/machinery/telecomms/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/current_user = usr
	if(!HAS_SILICON_ACCESS(current_user))
		if(!istype(current_user.get_active_held_item(), /obj/item/multitool))
			return

	var/obj/item/multitool/heldmultitool = get_multitool(current_user)

	switch(action)
		if("toggle")
			toggled = !toggled
			update_power()
			update_appearance()
			current_user.log_message("toggled [toggled ? "On" : "Off"] [src].", LOG_GAME)
			. = TRUE
		if("id")
			if(params["value"])
				if(length(params["value"]) > 32)
					to_chat(current_user, span_warning("Error: Machine ID too long!"))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
					return
				else
					id = params["value"]
					current_user.log_message("has changed the ID for [src] to [id].", LOG_GAME)
					. = TRUE
		if("network")
			if(params["value"])
				if(length(params["value"]) > 15)
					to_chat(current_user, span_warning("Error: Network name too long!"))
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
					return
				else
					for(var/obj/machinery/telecomms/linked_machine in links)
						remove_link(linked_machine)
					network = params["value"]
					links = list()
					current_user.log_message("has changed the network for [src] to [network].", LOG_GAME)
					. = TRUE
		if("tempfreq")
			if(params["value"])
				tempfreq = text2num(params["value"]) * 10
		if("freq")
			if(tempfreq in banned_frequencies)
				to_chat(current_user, span_warning("Error: Interference preventing filtering frequency: \"[tempfreq / 10] kHz\""))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			else
				if(!(tempfreq in freq_listening))
					freq_listening.Add(tempfreq)
					current_user.log_message("added frequency [tempfreq] for [src].", LOG_GAME)
					. = TRUE
		if("delete")
			freq_listening.Remove(params["value"])
			current_user.log_message("removed frequency [params["value"]] for [src].", LOG_GAME)
			. = TRUE
		if("unlink")
			var/obj/machinery/telecomms/machine_to_unlink = links[text2num(params["value"])]
			if(machine_to_unlink)
				. = remove_link(machine_to_unlink, current_user)
		if("link")
			if(heldmultitool)
				var/obj/machinery/telecomms/machine_to_link = heldmultitool.buffer
				. = add_new_link(machine_to_link, current_user)
		if("buffer")
			heldmultitool.set_buffer(src)
			. = TRUE
		if("flush")
			heldmultitool.set_buffer(null)
			. = TRUE

	add_act(action, params)
	. = TRUE

/// Adds new_connection to src's links list AND vice versa. Also updates `links_by_telecomms_type`.
/obj/machinery/telecomms/proc/add_new_link(obj/machinery/telecomms/new_connection, mob/user)
	if(!istype(new_connection) || new_connection == src)
		return FALSE

	if((new_connection in links) && (src in new_connection.links))
		return FALSE

	links |= new_connection
	new_connection.links |= src

	LAZYADDASSOCLIST(links_by_telecomms_type, new_connection.telecomms_type, new_connection)
	LAZYADDASSOCLIST(new_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		user.log_message("linked [src] for [new_connection].", LOG_GAME)
	return TRUE

/// Removes old_connection from src's links list AND vice versa. Also updates `links_by_telecomms_type`.
/obj/machinery/telecomms/proc/remove_link(obj/machinery/telecomms/old_connection, mob/user)
	if(!istype(old_connection) || old_connection == src)
		return FALSE

	if(old_connection in links)
		links -= old_connection
		LAZYREMOVEASSOC(links_by_telecomms_type, old_connection.telecomms_type, old_connection)

	if(src in old_connection.links)
		old_connection.links -= src
		LAZYREMOVEASSOC(old_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		user.log_message("unlinked [src] and [old_connection].", LOG_GAME)

	return TRUE

/**
 * Wrapper for adding additional options to a machine's interface.
 *
 * Returns a list, or `null` if it wasn't implemented by the machine.
 */
/obj/machinery/telecomms/proc/add_option()
	return

/obj/machinery/telecomms/bus/add_option()
	var/list/data = list()
	data["type"] = "bus"
	data["changefrequency"] = change_frequency
	return data

/obj/machinery/telecomms/relay/add_option()
	var/list/data = list()
	data["type"] = "relay"
	data["broadcasting"] = broadcasting
	data["receiving"] = receiving
	return data

/**
 * Wrapper for adding another time of action for `ui_act()`, rather than
 * having you override `ui_act` yourself.
 *
 * Returns `TRUE` if the action was handled, nothing if not.
 */
/obj/machinery/telecomms/proc/add_act(action, params)
	return

/obj/machinery/telecomms/relay/add_act(action, params)
	switch(action)
		if("broadcast")
			broadcasting = !broadcasting
			. = TRUE
		if("receive")
			receiving = !receiving
			. = TRUE

/obj/machinery/telecomms/bus/add_act(action, params)
	switch(action)
		if("change_freq")
			var/newfreq = text2num(params["value"]) * 10
			if(newfreq)
				if(newfreq < 10000)
					change_frequency = newfreq
					. = TRUE
				else
					change_frequency = 0

/// Returns a multitool from a user depending on their mobtype.
/obj/machinery/telecomms/proc/get_multitool(mob/user)
	. = null
	if(isAI(user))
		var/mob/living/silicon/ai/U = user
		return U.aiMulti

	var/obj/item/held_item = user.get_active_held_item()
	if(QDELETED(held_item))
		return
	held_item = held_item.get_proxy_attacker_for(src, user) //for borgs omni tool
	if(held_item.tool_behaviour != TOOL_MULTITOOL)
		return

	if(!HAS_SILICON_ACCESS(user))
		return held_item
	if(iscyborg(user) && in_range(user, src))
		return held_item
