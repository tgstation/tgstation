#define DEFAULT_ANNOUNCEMENT_SOUND "default_announcement"

/client/proc/cmd_change_command_name()
	set category = "Admin.Events"
	set name = "Change Command Name"

	if(!check_rights(R_ADMIN))
		return

	var/input = input(usr, "Please input a new name for Central Command.", "What?", "") as text|null
	if(!input)
		return
	change_command_name(input)
	message_admins("[key_name_admin(src)] has changed Central Command's name to [input]")
	log_admin("[key_name(src)] has changed the Central Command name to: [input]")

/client/proc/cmd_admin_create_centcom_report()
	set category = "Admin.Events"
	set name = "Create Command Report"

	if(!check_rights(R_ADMIN))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Command Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	var/datum/command_report_menu/tgui = new(usr)
	tgui.ui_interact(usr)

/// Datum for holding the TGUI window for command reports.
/datum/command_report_menu
	/// The name of central command.
	var/command_name
	/// The actual contents of the report we're going to send.
	var/command_report_content
	/// Whether the report's contents are announced.
	var/announce_contents = FALSE
	/// The sound that's going to accompany our message.
	var/played_sound = DEFAULT_ANNOUNCEMENT_SOUND
	/// The mob using the UI.
	var/mob/ui_user

/datum/command_report_menu/New(mob/user)
	ui_user = user
	command_name = command_name()

/datum/command_report_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/command_report_menu/ui_close()
	qdel(src)

/datum/command_report_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CommandReport")
		ui.open()

/datum/command_report_menu/ui_data(mob/user)
	var/list/data = list()
	// The command name the user sets
	data["command_name"] = command_name
	// The command name set globally
	data["global_command_name"] = command_name()
	data["command_report_content"] = command_report_content
	data["announce_contents"] = announce_contents
	data["played_sound"] = played_sound
	return data

/datum/command_report_menu/ui_static_data(mob/user)
	var/list/data = list()
	data["announcer_sounds"] = list(DEFAULT_ANNOUNCEMENT_SOUND) + GLOB.announcer_keys
	return data

/datum/command_report_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("update_command_name")
			command_name = params["updated_name"]
			. = TRUE
		if("update_report_contents")
			command_report_content = params["updated_contents"]
			. = TRUE
		if("set_report_sound")
			played_sound = params["picked_sound"]
			. = TRUE
		if("toggle_announce")
			announce_contents = !announce_contents
			. = TRUE
		if("submit_report")
			if(!command_name)
				to_chat(ui_user, "<span class='danger'>You can't send a report with no command name.</span>")
				return
			if(!command_report_content)
				to_chat(ui_user, "<span class='danger'>You can't send a report with no contents.</span>")
				return
			send_announcement()
			. = TRUE

	return

/// Send the announcement and report with all of our variables.
/datum/command_report_menu/proc/send_announcement()
	/// Our current command name to swap back to after sending the report.
	var/original_command_name = command_name()
	change_command_name(command_name)

	if(played_sound == DEFAULT_ANNOUNCEMENT_SOUND)
		played_sound = SSstation.announcer.get_rand_report_sound()

	if(announce_contents)
		priority_announce(command_report_content, null, played_sound, has_important_message = TRUE)
	print_command_report(command_report_content, "[announce_contents ? "Classified " : ""][command_name] Update", !announce_contents)

	change_command_name(original_command_name)

	log_admin("[key_name(ui_user)] has created a command report: [command_report_content], send from [command_name]")
	message_admins("[key_name_admin(ui_user)] has created a command report from [command_name].")

#undef DEFAULT_ANNOUNCEMENT_SOUND
