///Allows an admin to send messages on PDA
/client/proc/message_pda()
	set name = "PDA Message"
	set category = "Admin.Events"

	if(!holder || !check_rights(R_ADMIN))
		return

	holder.message_pda()

///Opens up the PDA Message Panel
/datum/admins/proc/message_pda()
	if(!check_rights(R_ADMIN))
		return

	if(!length(GLOB.TabletMessengers))
		to_chat(usr, span_warning("ERROR: There are no users you can send a message to"))
		return

	var/datum/admin_pda_panel/ui = new(usr)
	ui.ui_interact(usr)

/// Panel
/datum/admin_pda_panel

/datum/admin_pda_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminPDA")
		ui.open()

/datum/admin_pda_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_pda_panel/ui_static_data(mob/user)
	var/list/data = list()
	var/list/available_messengers = list()
	for(var/msgr_ref in get_messengers_sorted(FALSE))
		var/datum/computer_file/program/messenger/msgr = GLOB.TabletMessengers[msgr_ref]
		available_messengers[REF(msgr)] = list(
			ref = REF(msgr),
			username = get_messenger_name(msgr),
			invisible = msgr.invisible,
		)
	data["users"] = available_messengers
	return data

/datum/admin_pda_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("sendMessage")
			var/targets = list()
			var/spam = params["spam"]
			var/ref = params["ref"]
			var/force = params["force"]
			if(!spam && (ref in GLOB.TabletMessengers))
				targets += GLOB.TabletMessengers[ref]
			else
				for(var/msgr_ref in get_messengers_sorted(FALSE))
					var/datum/computer_file/program/messenger/msgr = GLOB.TabletMessengers[msgr_ref]
					if(msgr.invisible && !params["include_invisible"])
						continue
					targets += msgr

			if(!length(targets))
				to_chat(usr, span_warning("ERROR: Target is unavailable."))
				return FALSE

			var/datum/pda_msg/msg = new(params["message"], TRUE, everyone = spam)

			var/datum/signal/subspace/messaging/tablet_msg/signal = new(null, list(
				"fakename" = params["name"],
				"fakejob" = params["job"],
				"message" = msg,
				"ref" = null,
				"targets" = targets,
				"rigged" = FALSE,
				"automated" = FALSE,
			))

			if(force)
				signal.broadcast()
			else
				signal.levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
				signal.send_to_receivers()

			if(!(force || signal.data["reject"]))
				to_chat(usr, span_warning("ERROR: PDA message was rejected by the telecomms setup."))
				return FALSE

			message_admins("[key_name_admin(usr)] sent a custom PDA message to [spam ? "everyone" : get_messenger_name(GLOB.TabletMessengers[params["ref"]])].")
			log_admin("[key_name(usr)] sent a custom PDA message to [spam ? "everyone" : get_messenger_name(GLOB.TabletMessengers[params["ref"]])]. Message: [params["message"]].")
			log_pda("[key_name(usr)] sent an admin custom PDA message to [spam ? "everyone" : get_messenger_name(GLOB.TabletMessengers)]. Message: [params["message"]]")
			return TRUE
