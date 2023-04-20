// Admin Tab - Event Verbs

ADMIN_VERB_CONTEXT_MENU(subtle_message, "Subtle Message", R_ADMIN, mob/target in world)
	message_admins("[key_name_admin(user)] has started answering [ADMIN_LOOKUPFLW(target)]'s prayer.")
	var/msg = input("Message:", text("Subtle PM to [target.key]")) as text|null

	if(!msg)
		message_admins("[key_name_admin(user)] decided not to answer [ADMIN_LOOKUPFLW(target)]'s prayer")
		return

	target.balloon_alert(target, "you hear a voice")
	to_chat(target, "<i>You hear a voice in your head... <b>[msg]</i></b>", confidential = TRUE)

	log_admin("SubtlePM: [key_name(user)] -> [key_name(target)] : [msg]")
	msg = span_adminnotice("<b> SubtleMessage: [key_name_admin(user)] -> [key_name_admin(target)] :</b> [msg]")
	message_admins(msg)
	admin_ticket_log(target, msg)

ADMIN_VERB_CONTEXT_MENU(headset_message, "Headset Message", R_ADMIN, mob/living/target in world)
	user.admin_headset_message(target)

/client/proc/admin_headset_message(mob/target, sender = null)
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

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(global_narrate, "Global Narrate", "Send direct chat output to all connected clients.", R_ADMIN|R_SERVER, VERB_CATEGORY_EVENTS)
	var/msg = input(user, "Message:", text("Enter the text you wish to appear to everyone:")) as text|null
	if (!msg)
		return

	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(user)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(user)] Sent a global narrate"))

ADMIN_VERB(narrate_local, "Local Narrate", "Send direct chat output to all clients within the given range.", R_ADMIN, VERB_CATEGORY_EVENTS, atom/around)
	var/range = input(user, "Range:", "Narrate to mobs within how many tiles:", 7) as num|null
	if(!range)
		return

	var/msg = input(user, "Message:", text("Enter the text you wish to appear to everyone within view:")) as text|null
	if (!msg)
		return

	for(var/mob/M in view(range, around))
		to_chat(M, msg)

	log_admin("LocalNarrate: [key_name(user)] at [AREACOORD(around)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(usr)] at [ADMIN_VERBOSEJMP(around)]:</b> [msg]<BR>"))

ADMIN_VERB_CONTEXT_MENU(narrate_direct, "Direct Narrate", R_ADMIN, mob/target in world)
	var/msg = input(user, "Message:", "Enter the text you wish to appear to your target") as text|null
	if(!msg)
		return

	to_chat(target, msg)
	log_admin("DirectNarrate: [key_name(user)] to ([target.name]/[target.key]): [msg]")
	msg = span_adminnotice("<b> DirectNarrate: [key_name(user)] to ([target.name]/[target.key]):</b> [msg]<BR>")
	message_admins(msg)
	admin_ticket_log(target, msg)

ADMIN_VERB(add_custom_ai_law, "Ass Custom AI Law", "Adds a custom freeform law, as an ion law.", R_FUN, VERB_CATEGORY_EVENTS)
	var/input = input(user, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(user)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(user)] has added a new AI law - [input]")

	var/show_log = tgui_alert(user, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 100 : 0)

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announce_chance = announce_ion_laws
	ion.ionMessage = input

ADMIN_VERB(call_shuttle, "Call Shuttle", "", R_ADMIN, VERB_CATEGORY_EVENTS)
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
	log_admin("[key_name(user)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-called the emergency shuttle[confirm == "Yes (No Recall)" ? " (non-recallable)" : ""]."))

ADMIN_VERB(cancel_shuttle, "Cancel Shuttle", "", R_ADMIN, VERB_CATEGORY_EVENTS)
	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(SSshuttle.admin_emergency_no_recall)
		SSshuttle.admin_emergency_no_recall = FALSE

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	log_admin("[key_name(user)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-recalled the emergency shuttle."))

ADMIN_VERB(disable_shuttle, "Disable Shuttle", "", R_ADMIN, VERB_CATEGORY_EVENTS)
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
	priority_announce("Warning: Emergency Shuttle uplink failure, shuttle disabled until further notice.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

ADMIN_VERB(enable_shuttle, "Enable Shuttle", "", R_ADMIN, VERB_CATEGORY_EVENTS)
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
	priority_announce("Warning: Emergency Shuttle uplink reestablished, shuttle enabled.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

ADMIN_VERB(hostile_environment, "Hostile Environment", "", R_ADMIN, VERB_CATEGORY_EVENTS)
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

ADMIN_VERB(toggle_nuke, "Toggle Nuke", "View, arm, and disarm nuclear devices.", R_FUN|R_DEBUG, VERB_CATEGORY_EVENTS, obj/machinery/nuclearbomb/nuke in world)
	if(!nuke.timing)
		var/set_time = tgui_input_number(
			user,
			"How long until detonation? (in seconds)",
			"Toggle Nuke",
			90,
			min_value = nuke.minimum_timer_set,
			max_value = nuke.maximum_timer_set,
			)
		if(!set_time)
			return

		if(nuke.safety)
			nuke.toggle_nuke_safety()
		nuke.timer_set = set_time
		nuke.toggle_nuke_armed()

	else
		if(!nuke.safety)
			nuke.toggle_nuke_safety() // automatically disarms
		else
			nuke.toggle_nuke_armed()

	log_admin("[key_name(user)] [nuke.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(nuke)].")
	message_admins("[ADMIN_LOOKUPFLW(user.mob)] [nuke.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(nuke)].")

ADMIN_VERB(set_security_level, "Set Security Level", "Changes the security level. Announcement only.", R_ADMIN, VERB_CATEGORY_EVENTS)
	var/level = tgui_input_list(user, "Select Security Level:", "Set Security Level", SSsecurity_level.available_levels)
	if(!level)
		return

	SSsecurity_level.set_level(level)
	log_admin("[key_name(user)] changed the security level to [level]")
	message_admins("[key_name_admin(user)] changed the security level to [level]")

ADMIN_VERB(run_weather, "Run Weather", "Triggers weather on the z-level you choose.", R_FUN, VERB_CATEGORY_EVENTS)
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

ADMIN_VERB(add_mob_ability, "Add Mod Ability", "Adds an ability to your marked mob.", R_FUN, VERB_CATEGORY_EVENTS)
	if(!isliving(user.holder.marked_datum))
		to_chat(usr, span_warning("Error: Please mark a mob to add actions to it."))
		return

	var/mob/living/marked_mob = user.holder.marked_datum

	var/list/all_mob_actions = sort_list(subtypesof(/datum/action/cooldown/mob_cooldown), GLOBAL_PROC_REF(cmp_typepaths_asc))

	var/ability_type = tgui_input_list(user, "Choose an ability", "Ability", all_mob_actions)

	if(!ability_type)
		return

	var/datum/action/cooldown/mob_cooldown/add_ability

	var/make_sequence = tgui_alert(user, "Would you like this action to be a sequence of multiple abilities?", "Sequence Ability", list("Yes", "No"))
	if(make_sequence == "Yes")
		add_ability = new /datum/action/cooldown/mob_cooldown(marked_mob)
		add_ability.sequence_actions = list()
		while(!isnull(ability_type))
			var/ability_delay = tgui_input_number(user, "Enter the delay in seconds before the next ability in the sequence is used", "Ability Delay", 2)
			if(isnull(ability_delay) || ability_delay < 0)
				ability_delay = 0
			add_ability.sequence_actions[ability_type] = ability_delay * 1 SECONDS
			ability_type = tgui_input_list(user, "Choose a new sequence ability", "Sequence Ability", all_mob_actions)
		var/ability_cooldown = tgui_input_number(user, "Enter the sequence abilities cooldown in seconds", "Ability Cooldown", 2)
		if(isnull(ability_cooldown) || ability_cooldown < 0)
			ability_cooldown = 2
		add_ability.cooldown_time = ability_cooldown * 1 SECONDS
		var/ability_melee_cooldown = tgui_input_number(user, "Enter the abilities melee cooldown in seconds", "Melee Cooldown", 2)
		if(isnull(ability_melee_cooldown) || ability_melee_cooldown < 0)
			ability_melee_cooldown = 2
		add_ability.melee_cooldown_time = ability_melee_cooldown * 1 SECONDS
		add_ability.name = tgui_input_text(user, "Choose ability name", "Ability name", "Generic Ability")
		add_ability.create_sequence_actions()
	else
		add_ability = new ability_type(marked_mob)

	if(isnull(marked_mob))
		return
	add_ability.Grant(marked_mob)

	message_admins("[key_name_admin(user)] added mob ability [ability_type] to mob [marked_mob].")
	log_admin("[key_name(user)] added mob ability [ability_type] to mob [marked_mob].")

ADMIN_VERB(remove_mob_ability, "Remove Mob Ability", "Removes an ability from your marked mob.", R_FUN, VERB_CATEGORY_EVENTS)
	if(!isliving(user.holder.marked_datum))
		to_chat(user, span_warning("Error: Please mark a mob to remove actions from it."))
		return

	var/mob/living/marked_mob = user.holder.marked_datum

	var/list/all_mob_actions = list()
	for(var/datum/action/cooldown/mob_cooldown/ability in marked_mob.actions)
		all_mob_actions.Add(ability)

	var/datum/action/cooldown/mob_cooldown/ability = tgui_input_list(user, "Remove an ability", "Ability", all_mob_actions)

	if(!ability)
		return

	var/ability_name = ability.name
	QDEL_NULL(ability)

	message_admins("[key_name_admin(user)] removed ability [ability_name] from mob [marked_mob].")
	log_admin("[key_name(user)] removed mob ability [ability_name] from mob [marked_mob].")

ADMIN_VERB(command_report_footnote, "Command Report Footnote", "Add a footnote to the roundstart command report.", R_ADMIN, VERB_CATEGORY_EVENTS)
	var/datum/command_footnote/command_report_footnote = new /datum/command_footnote()
	SScommunications.block_command_report++ //Add a blocking condition to the counter until the inputs are done.

	command_report_footnote.message = tgui_input_text(user, "This message will be attached to the bottom of the roundstart threat report.", "P.S.")
	if(!command_report_footnote.message)
		SScommunications.block_command_report--
		return

	command_report_footnote.signature = tgui_input_text(user, "Whose signature will appear on this footnote?", "Also sign here, here, aaand here.")

	if(!command_report_footnote.signature)
		command_report_footnote.signature = "Classified"

	SScommunications.command_report_footnotes += command_report_footnote
	SScommunications.block_command_report--

	message_admins("[user] has added a footnote to the command report: [command_report_footnote.message], signed [command_report_footnote.signature]")

/datum/command_footnote
	var/message
	var/signature

ADMIN_VERB(delay_command_report, "Delay Command Report", "Prevents the roundstart command report from being sent until toggled.", R_ADMIN, VERB_CATEGORY_EVENTS)
	if(SScommunications.block_command_report) //If it's anything other than 0, decrease. If 0, increase.
		SScommunications.block_command_report--
		message_admins("[user] has enabled the roundstart command report.")
	else
		SScommunications.block_command_report++
		message_admins("[user] has delayed the roundstart command report.")
