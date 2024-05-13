// Admin Tab - Event Verbs

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_subtle_message, R_ADMIN, "Subtle Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in world)
	message_admins("[key_name_admin(user)] has started answering [ADMIN_LOOKUPFLW(target)]'s prayer.")
	var/msg = input(user, "Message:", "Subtle PM to [target.key]") as text|null

	if(!msg)
		message_admins("[key_name_admin(user)] decided not to answer [ADMIN_LOOKUPFLW(target)]'s prayer")
		return

	target.balloon_alert(target, "you hear a voice")
	to_chat(target, "<i>You hear a voice in your head... <b>[msg]</i></b>", confidential = TRUE)

	log_admin("SubtlePM: [key_name(user)] -> [key_name(target)] : [msg]")
	msg = span_adminnotice("<b> SubtleMessage: [key_name_admin(user)] -> [key_name_admin(target)] :</b> [msg]")
	message_admins(msg)
	admin_ticket_log(target, msg)
	BLACKBOX_LOG_ADMIN_VERB("Subtle Message")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_headset_message, R_ADMIN, "Headset Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in world)
	user.admin_headset_message(target)

/client/proc/admin_headset_message(mob/target in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/human_recipient
	var/mob/living/silicon/silicon_recipient

	if(!check_rights(R_ADMIN))
		return


	if(ishuman(target))
		human_recipient = target
		if(!istype(human_recipient.ears, /obj/item/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset.", confidential = TRUE)
			return
	else if(issilicon(target))
		silicon_recipient = target
		if(!istype(silicon_recipient.radio, /obj/item/radio))
			to_chat(usr, "The silicon you are trying to contact does not have a radio installed.", confidential = TRUE)
			return
	else
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human or /mob/living/silicon", confidential = TRUE)
		return

	if (!sender)
		sender = input("Who is the message from?", "Sender") as null|anything in list(RADIO_CHANNEL_CENTCOM,RADIO_CHANNEL_SYNDICATE)
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(target)]'s [sender] request.")
	var/input = input("Please enter a message to reply to [key_name(target)] via their headset.","Outgoing message from [sender]", "") as text|null
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(target)]'s [sender] request.")
		return

	log_directed_talk(mob, target, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(target)]'s [sender] message with: \"[input]\"")
	target.balloon_alert(target, "you hear a voice")
	to_chat(target, span_hear("You hear something crackle in your [human_recipient ? "ears" : "radio receiver"] for a moment before a voice speaks. \"Please stand by for a message from [sender == "Syndicate" ? "your benefactor" : "Central Command"]. Message as follows[sender == "Syndicate" ? ", agent." : ":"] <b>[input].</b> Message ends.\""), confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Headset Message")

ADMIN_VERB(cmd_admin_world_narrate, R_ADMIN, "Global Narrate", "Send a direct narration to all connected players.", ADMIN_CATEGORY_EVENTS)
	var/msg = input(user, "Message:", "Enter the text you wish to appear to everyone:") as text|null
	if (!msg)
		return
	to_chat(world, "[msg]", confidential = TRUE)
	log_admin("GlobalNarrate: [key_name(user)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(user)] Sent a global narrate"))
	BLACKBOX_LOG_ADMIN_VERB("Global Narrate")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_local_narrate, R_ADMIN, "Local Narrate", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, atom/locale in world)
	var/range = input(user, "Range:", "Narrate to mobs within how many tiles:", 7) as num|null
	if(!range)
		return
	var/msg = input(user, "Message:", "Enter the text you wish to appear to everyone within view:") as text|null
	if (!msg)
		return
	for(var/mob/M in view(range, locale))
		to_chat(M, msg, confidential = TRUE)

	log_admin("LocalNarrate: [key_name(user)] at [AREACOORD(locale)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(user)] at [ADMIN_VERBOSEJMP(locale)]:</b> [msg]<BR>"))
	BLACKBOX_LOG_ADMIN_VERB("Local Narrate")

ADMIN_VERB_AND_CONTEXT_MENU(cmd_admin_direct_narrate, R_ADMIN, "Direct Narrate", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target)
	var/msg = input(user, "Message:", "Enter the text you wish to appear to your target:") as text|null

	if( !msg )
		return

	to_chat(target, msg, confidential = TRUE)
	log_admin("DirectNarrate: [key_name(user)] to ([key_name(target)]): [msg]")
	msg = span_adminnotice("<b> DirectNarrate: [key_name_admin(user)] to ([key_name_admin(target)]):</b> [msg]<BR>")
	message_admins(msg)
	admin_ticket_log(target, msg)
	BLACKBOX_LOG_ADMIN_VERB("Direct Narrate")

ADMIN_VERB(cmd_admin_add_freeform_ai_law, R_ADMIN, "Add Custom AI Law", "Add a custom law to the Silicons.", ADMIN_CATEGORY_EVENTS)
	var/input = input(user, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(user)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(user)] has added a new AI law - [input]")

	var/show_log = tgui_alert(user, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 100 : 0)

	var/datum/round_event/ion_storm/add_law_only/ion = new
	ion.announce_chance = announce_ion_laws
	ion.ionMessage = input

	BLACKBOX_LOG_ADMIN_VERB("Add Custom AI Law")

ADMIN_VERB(call_shuttle, R_ADMIN, "Call Shuttle", "Force a shuttle call with additional modifiers.", ADMIN_CATEGORY_EVENTS)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "Yes (No Recall)", "No"))
	switch(confirm)
		if(null, "No")
			return
		if("Yes (No Recall)")
			SSshuttle.admin_emergency_no_recall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	BLACKBOX_LOG_ADMIN_VERB("Call Shuttle")
	log_admin("[key_name(user)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-called the emergency shuttle[confirm == "Yes (No Recall)" ? " (non-recallable)" : ""]."))

ADMIN_VERB(cancel_shuttle, R_ADMIN, "Cancel Shuttle", "Recall the shuttle, regardless of circumstances.", ADMIN_CATEGORY_EVENTS)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency.cancel()
	BLACKBOX_LOG_ADMIN_VERB("Cancel Shuttle")
	log_admin("[key_name(user)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-recalled the emergency shuttle."))

ADMIN_VERB(disable_shuttle, R_ADMIN, "Disable Shuttle", "Those fuckers aren't getting out.", ADMIN_CATEGORY_EVENTS)
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(user, span_warning("Error, shuttle is already disabled."))
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] disabled the shuttle."))

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.admin_emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce(
		text = "Emergency Shuttle uplink failure, shuttle disabled until further notice.",
		title = "Uplink Failure",
		sound = 'sound/misc/announce_dig.ogg',
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "grey",
	)

ADMIN_VERB(enable_shuttle, R_ADMIN, "Enable Shuttle", "Those fuckers ARE getting out.", ADMIN_CATEGORY_EVENTS)
	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(user, span_warning("Error, shuttle not disabled."))
		return

	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(user)] enabled the emergency shuttle."))
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED) //If everything goes to shit, fix it.
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce(
		text = "Emergency Shuttle uplink reestablished, shuttle enabled.",
		title = "Uplink Restored",
		sound = 'sound/misc/announce_dig.ogg',
		sender_override = "Emergency Shuttle Uplink Alert",
		color_override = "green",
	)

ADMIN_VERB(hostile_environment, R_ADMIN, "Hostile Environment", "Disable the shuttle, naturally.", ADMIN_CATEGORY_EVENTS)
	switch(tgui_alert(user, "Select an Option", "Hostile Environment Manager", list("Enable", "Disable", "Clear All")))
		if("Enable")
			if (SSshuttle.hostile_environments["Admin"] == TRUE)
				to_chat(user, span_warning("Error, admin hostile environment already enabled."))
			else
				message_admins(span_adminnotice("[key_name_admin(user)] Enabled an admin hostile environment"))
				SSshuttle.registerHostileEnvironment("Admin")
		if("Disable")
			if (!SSshuttle.hostile_environments["Admin"])
				to_chat(user, span_warning("Error, no admin hostile environment found."))
			else
				message_admins(span_adminnotice("[key_name_admin(user)] Disabled the admin hostile environment"))
				SSshuttle.clearHostileEnvironment("Admin")
		if("Clear All")
			message_admins(span_adminnotice("[key_name_admin(user)] Disabled all current hostile environment sources"))
			SSshuttle.hostile_environments.Cut()
			SSshuttle.checkHostileEnvironment()

ADMIN_VERB(toggle_nuke, R_DEBUG|R_ADMIN, "Toggle Nuke", "Arm or disarm a nuke.", ADMIN_CATEGORY_EVENTS, obj/machinery/nuclearbomb/nuke in world)
	if(!nuke.timing)
		var/newtime = input(user, "Set activation timer.", "Activate Nuke", "[nuke.timer_set]") as num|null
		if(!newtime)
			return
		nuke.timer_set = newtime
	nuke.toggle_nuke_safety()
	nuke.toggle_nuke_armed()

	log_admin("[key_name(user)] [nuke.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(nuke)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] [nuke.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(nuke)].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Nuke", "[nuke.timing]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

ADMIN_VERB(change_sec_level, R_ADMIN, "Set Security Level", "Changes the security level. Announcement effects only.", ADMIN_CATEGORY_EVENTS)
	var/level = tgui_input_list(user, "Select Security Level:", "Set Security Level", SSsecurity_level.available_levels)

	if(!level)
		return

	SSsecurity_level.set_level(level)

	log_admin("[key_name(user)] changed the security level to [level]")
	message_admins("[key_name_admin(user)] changed the security level to [level]")
	BLACKBOX_LOG_ADMIN_VERB("Set Security Level [capitalize(level)]")

ADMIN_VERB(run_weather, R_FUN, "Run Weather", "Triggers specific weather on the z-level you choose.", ADMIN_CATEGORY_EVENTS)
	var/weather_type = input(user, "Choose a weather", "Weather")  as null|anything in sort_list(subtypesof(/datum/weather), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!weather_type)
		return

	var/turf/T = get_turf(user.mob)
	var/z_level = input(user, "Z-Level to target?", "Z-Level", T?.z) as num|null
	if(!isnum(z_level))
		return

	SSweather.run_weather(weather_type, z_level)

	message_admins("[key_name_admin(user)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(user)] started weather of type [weather_type] on the z-level [z_level].")
	BLACKBOX_LOG_ADMIN_VERB("Run Weather")

ADMIN_VERB(command_report_footnote, R_ADMIN, "Command Report Footnote", "Adds a footnote to the roundstart command report.", ADMIN_CATEGORY_EVENTS)
	var/datum/command_footnote/command_report_footnote = new /datum/command_footnote()
	GLOB.communications_controller.block_command_report += 1 //Add a blocking condition to the counter until the inputs are done.

	command_report_footnote.message = tgui_input_text(user, "This message will be attached to the bottom of the roundstart threat report. Be sure to delay the roundstart report if you need extra time.", "P.S.")
	if(!command_report_footnote.message)
		GLOB.communications_controller.block_command_report -= 1
		qdel(command_report_footnote)
		return

	command_report_footnote.signature = tgui_input_text(user, "Whose signature will appear on this footnote?", "Also sign here, here, aaand here.")

	if(!command_report_footnote.signature)
		command_report_footnote.signature = "Classified"

	GLOB.communications_controller.command_report_footnotes += command_report_footnote
	GLOB.communications_controller.block_command_report--

	message_admins("[user] has added a footnote to the command report: [command_report_footnote.message], signed [command_report_footnote.signature]")

/datum/command_footnote
	var/message
	var/signature

ADMIN_VERB(delay_command_report, R_FUN, "Delay Command Report", "Prevents the roundstart command report from being sent; or forces it to send it delayed.", ADMIN_CATEGORY_EVENTS)
	GLOB.communications_controller.block_command_report = !GLOB.communications_controller.block_command_report
	message_admins("[key_name_admin(user)] has [(GLOB.communications_controller.block_command_report ? "delayed" : "sent")] the roundstart command report.")
