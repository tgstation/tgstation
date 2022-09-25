GLOBAL_DATUM_INIT(fax_manager, /datum/fax_manager, new)

/**
 * # Request Manager
 *
 * Handles all player requests (prayers, centcom requests, syndicate requests)
 * that occur in the duration of a round.
 */

/datum/fax_manager
	var/list/requests = list()

/datum/fax_manager/Destroy(force, ...)
	QDEL_LIST(requests)
	return ..()

/datum/fax_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FaxManager")
		ui.open()

/datum/fax_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/fax_manager/ui_static_data(mob/user)
	var/list/data = list()
	// Record additional faxes on a separate list
	data["additional_faxes"] = GLOB.additional_faxes_list + GLOB.syndicate_faxes_list
	return data

/datum/fax_manager/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/FAX in GLOB.machines)
		var/list/fax_data = list()
		fax_data["fax_name"] = FAX.fax_name
		fax_data["fax_id"] = FAX.fax_id
		fax_data["syndicate_network"] = FAX.syndicate_network
		data["faxes"] += list(fax_data)
	for(var/list/REQUEST in requests)
		var/list/request = list()
		request["id_message"] = REQUEST["id_message"]
		request["time"] = REQUEST["time"]
		var/mob/sender = REQUEST["sender"]
		request["sender_name"] = sender.name
		request["sender_fax_id"] = REQUEST["sender_fax_id"]
		request["sender_fax_name"] = REQUEST["sender_fax_name"]
		request["receiver_fax_name"] = REQUEST["receiver_fax_name"]
		data["requests"] += list(request)
	return data

/datum/fax_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("send")
			for(var/obj/machinery/fax/FAX in GLOB.machines)
				if (FAX.fax_id == params["fax_id"])
					var/obj/item/paper/paper = new()
					paper.add_raw_text(params["message"])
					FAX.receive(paper, params["fax_name"])
					return TRUE
		if("flw_fax")
			for(var/obj/machinery/fax/FAX in GLOB.machines)
				if (FAX.fax_id == params["fax_id"])
					usr.client.admin_follow(FAX)
					return TRUE
		if("read_message")
			var/list/REQUEST = get_request(params["id_message"])
			var/obj/item/paper/request/paper = REQUEST["paper"]
			paper.ui_interact(usr)
			return TRUE
		if("flw")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.admin_follow(REQUEST["sender"])
			return TRUE
		if("pp")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.holder.show_player_panel(REQUEST["sender"])
			return TRUE
		if("vv")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.debug_variables(REQUEST["sender"])
			return TRUE
		if("sm")
			var/list/REQUEST = get_request(params["id_message"])
			usr.client.cmd_admin_subtle_message(REQUEST["sender"])
			return TRUE
		if("logs")
			var/list/REQUEST = get_request(params["id_message"])
			if(!ismob(REQUEST["sender"]))
				to_chat(usr, "This can only be used on instances of type /mob.", confidential = TRUE)
				return TRUE
			show_individual_logging_panel(REQUEST["sender"], null, null)
			return TRUE
		if("smite")
			var/list/REQUEST = get_request(params["id_message"])
			if(!check_rights(R_FUN))
				to_chat(usr, "Insufficient permissions to smite, you require +FUN", confidential = TRUE)
				return TRUE
			var/mob/living/carbon/human/H = REQUEST["sender"]
			if (!H || !istype(H))
				to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential = TRUE)
				return TRUE
			usr.client.smite(H)
			return TRUE

/datum/fax_manager/proc/get_request(id_message)
	for(var/list/REQUEST in requests)
		if(REQUEST["id_message"] == id_message)
			return REQUEST

/datum/fax_manager/proc/receive_request(mob/sender, obj/machinery/fax/sender_fax, receiver_fax_name, obj/item/paper/paper, receiver_color)
	var/list/request = list()
	var/obj/item/paper/request/message = new()
	request["id_message"] = requests.len
	request["time"] = gameTimestamp()
	request["sender"] = sender
	request["sender_fax_id"] = sender_fax.fax_id
	request["sender_fax_name"] = sender_fax.fax_name
	request["receiver_fax_name"] = receiver_fax_name
	message.copy_properties(paper)
	request["paper"] = message
	requests += list(request)
	var/msg = span_adminnotice("<b><font color=[receiver_color]>[sanitize(receiver_fax_name)] fax</font> received a message from [sanitize(sender_fax.fax_name)][ADMIN_JMP(sender_fax)]/[ADMIN_FULLMONTY(sender)]</b>")
	to_chat(GLOB.admins, msg, confidential = TRUE)
	for(var/client/admin in GLOB.admins)
		if(admin.prefs.chat_toggles & CHAT_PRAYER && admin.prefs.toggles & SOUND_PRAYERS)
			SEND_SOUND(admin, sound('sound/machines/printer.ogg'))

// A special piece of paper for the administrator that will open the interface no matter what.
/obj/item/paper/request/ui_status()
	return UI_INTERACTIVE

// I'm sure there's a better way to transfer it, I just couldn't find it
/obj/item/paper/request/proc/copy_properties(obj/item/paper/paper)
	raw_text_inputs = paper.raw_text_inputs
	raw_stamp_data = paper.raw_stamp_data
	raw_field_input_data = paper.raw_field_input_data
	show_written_words = paper.show_written_words
	stamp_cache = paper.stamp_cache
	contact_poison = paper.contact_poison
	contact_poison_volume = paper.contact_poison_volume
	default_raw_text = paper.default_raw_text
	input_field_count = paper.input_field_count
