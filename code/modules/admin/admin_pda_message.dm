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
	/// PDA which have players(and we can send them message)
	var/available_pdas = list()

/datum/admin_pda_panel/New()
	for(var/obj/item/modular_computer/computer in GLOB.TabletMessengers)
		for(var/datum/computer_file/program/messenger/app in computer.stored_files)
			if(!computer.saved_identification || !computer.saved_job || app.monitor_hidden || app.invisible)
				continue
			available_pdas += list(list("tablet" = computer, "name" = computer.saved_identification))

/datum/admin_pda_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminPDA")
		ui.open()

/datum/admin_pda_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_pda_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["users"] = list()

	for(var/username in available_pdas)
		data["users"] += username["name"]
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
			for(var/target in available_pdas)
				if(!spam && target["name"] != params["user"])
					continue
				targets += target["tablet"]

			if(!length(targets))
				to_chat(usr, span_warning("ERROR: Target is unavaiable(or not choosed)."))
				return

			var/datum/signal/subspace/messaging/tablet_msg/signal = new(targets[1], list(
				"name" = params["name"],
				"job" = params["job"],
				"message" = html_decode(params["message"]),
				"ref" = FALSE,
				"targets" = targets,
				"emojis" = FALSE,
				"rigged" = FALSE,
				"photo" = FALSE,
				"automated" = FALSE,
			))

			signal.send_to_receivers()
			message_admins("[key_name_admin(usr)] has send custom PDA message to [spam ? "everyone" : params["user"]].")
			log_admin("[key_name(usr)] has send custom PDA message to [spam ? "everyone" : params["user"]]. Message: [params["message"]].")
