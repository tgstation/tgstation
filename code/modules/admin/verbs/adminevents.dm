// Admin Tab - Event Verbs

ADMIN_CONTEXT_ENTRY(context_subtle_message, "Subtle Message", R_ADMIN, mob/hearer in world)
	message_admins("[key_name_admin(src)] has started answering [ADMIN_LOOKUPFLW(hearer)]'s prayer.")

	var/msg = input("Message:", text("Subtle PM to [hearer.ckey]")) as text|null
	if(!msg)
		message_admins("[key_name_admin(src)] decided not to answer [ADMIN_LOOKUPFLW(hearer)]'s prayer")
		return

	hearer.balloon_alert(hearer, "you hear a voice")
	to_chat(hearer, "<i>You hear a voice in your head... <b>[msg]</i></b>")
	log_admin("SubtlePM: [key_name(usr)] -> [key_name(hearer)] : [msg]")
	msg = span_adminnotice("<b> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(hearer)] :</b> [msg]")
	message_admins(msg)
	admin_ticket_log(hearer, msg)

ADMIN_CONTEXT_ENTRY(contexxt_headset_message, "Headset Message", R_ADMIN, mob/living/carbon/human/hearer in world, sender in list(RADIO_CHANNEL_CENTCOM, RADIO_CHANNEL_SYNDICATE))
	if(!istype(hearer.ears, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset.", confidential = TRUE)
		return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(hearer)]'s [sender] request.")
	var/input = input("Please enter a message to reply to [key_name(hearer)] via their headset.","Outgoing message from [sender]", "") as text|null
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(hearer)]'s [sender] request.")
		return

	log_directed_talk(mob, hearer, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(hearer)]'s [sender] message with: \"[input]\"")
	hearer.balloon_alert(hearer, "you hear a voice")
	to_chat(hearer, span_hear("You hear something crackle in your ears for a moment before a voice speaks. \"Please stand by for a message from [sender == "Syndicate" ? "your benefactor" : "Central Command"]. Message as follows[sender == "Syndicate" ? ", agent." : ":"] <b>[input].</b> Message ends.\""), confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(events, global_narrate, "Global Narrate", "Send raw html to all conneted clients", R_ADMIN, raw_html as message)
	to_chat(world, "[raw_html]")
	log_admin("GlobalNarrate: [key_name(usr)] : [raw_html]")
	message_admins(span_adminnotice("[key_name_admin(usr)] Sent a global narrate"))

ADMIN_CONTEXT_ENTRY(context_local_narrate, "Local Narrate", R_ADMIN, atom/origin in view())
	var/range = input("Range:", "Narrate to mobs within how many tiles:", 7) as num|null
	if(!range)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone within view:")) as text|null
	if (!msg)
		return

	for(var/mob/hearer in view(range, origin))
		to_chat(hearer, msg)

	log_admin("LocalNarrate: [key_name(usr)] at [AREACOORD(origin)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(usr)] at [ADMIN_VERBOSEJMP(origin)]:</b> [msg]<BR>"))

ADMIN_CONTEXT_ENTRY(context_direct_narrate, "Direct Narrate", R_ADMIN, mob/hearer in world)
	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text|null
	if(!msg)
		return

	to_chat(hearer, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([key_name(hearer)]): [msg]")
	msg = span_adminnotice("<b> DirectNarrate: [key_name(usr)] to ([key_name(hearer)]):</b> [msg]<BR>")
	message_admins(msg)
	admin_ticket_log(hearer, msg)

ADMIN_VERB(fun, add_ion_law, "Add Ion Law", "Add an ion law to all silicons", R_FUN)
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")
	var/show_log = tgui_alert(usr, "Show ion message?", "Message", list("Yes", "No"))

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.ionMessage = input
	if(show_log == "Yes")
		ion.announce_chance = 100
		ion.announce(FALSE)
	ion.start()
	qdel(ion)

ADMIN_VERB(events, call_shuttle, "Call Shuttle", "", R_ADMIN)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	var/confirm = tgui_alert(usr, "You sure?", "Confirm", list("Yes", "Yes (No Recall)", "No"))
	switch(confirm)
		if(null, "No")
			return
		if("Yes (No Recall)")
			SSshuttle.admin_emergency_no_recall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-called the emergency shuttle[confirm == "Yes (No Recall)" ? " (non-recallable)" : ""]."))

ADMIN_VERB(events, recall_shuttle, "Recall Shuttle", "", R_ADMIN)
	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	SSshuttle.admin_emergency_no_recall &&= FALSE
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-recalled the emergency shuttle."))

ADMIN_VERB(events, disable_shuttle, "Disable Shuttle", "", R_ADMIN)
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle is already disabled."))
		return

	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] disabled the shuttle."))

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.admin_emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce("Warning: Emergency Shuttle uplink failure, shuttle disabled until further notice.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

ADMIN_VERB(events, enable_shuttle, "Enable Shuttle", "", R_ADMIN)
	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle not disabled."))
		return

	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] enabled the emergency shuttle."))
	SSshuttle.admin_emergency_no_recall = FALSE
	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED) //If everything goes to shit, fix it.
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce("Warning: Emergency Shuttle uplink reestablished, shuttle enabled.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

#define HOSTILE_ENVIRONMENT_ENABLE "Enable"
#define HOSTILE_ENVIRONMENT_DISABLE "Disable"
#define HOSTILE_ENVIRONMENT_CLEAR "Clear All"
#define HOSTILE_ENVIRONMENT_OPTIONS list(HOSTILE_ENVIRONMENT_ENABLE, HOSTILE_ENVIRONMENT_DISABLE, HOSTILE_ENVIRONMENT_CLEAR)

ADMIN_VERB(events, hostile_environments, "Hostile Environments", "", R_ADMIN)
	switch(tgui_alert(usr, "Select an Option", "Hostile Environment Manager", HOSTILE_ENVIRONMENT_OPTIONS))
		if(HOSTILE_ENVIRONMENT_ENABLE)
			if(SSshuttle.hostile_environments["Admin"])
				to_chat(usr, span_warning("Admin Hostile Environment already enabled!"))
				return
			message_admins(span_adminnotice("[key_name_admin(usr)] Enabled an admin hostile environment"))
			SSshuttle.registerHostileEnvironment("Admin")

		if(HOSTILE_ENVIRONMENT_DISABLE)
			if(!SSshuttle.hostile_environments["Admin"])
				to_chat(usr, span_warning("Admin Hostile Environment not enabled!"))
				return
			message_admins(span_adminnotice("[key_name_admin(usr)] Disabled the admin hostile environment"))
			SSshuttle.clearHostileEnvironment("Admin")

		if(HOSTILE_ENVIRONMENT_CLEAR)
			if(tgui_alert(usr, "Are you sure?", "Hostile Environment Manager", list("Yes", "No")) != "Yes")
				return
			message_admins(span_adminnotice("[key_name_admin(usr)] Disabled all current hostile environment sources"))
			SSshuttle.hostile_environments.Cut()
			SSshuttle.checkHostileEnvironment()

ADMIN_VERB(events, toggle_nuke, "Toggle Nuke", "", (R_ADMIN|R_DEBUG), obj/machinery/nuclearbomb/nuke in GLOB.nuke_list)
	if(!nuke.timing)
		var/newtime = input(usr, "Set activation timer.", "Activate Nuke", "[nuke.timer_set]") as num|null
		if(!newtime)
			return
		nuke.timer_set = newtime
	nuke.toggle_nuke_safety()
	nuke.toggle_nuke_armed()

	log_admin("[key_name(usr)] [nuke.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(nuke)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] [nuke.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(nuke)].")

ADMIN_VERB(events, set_security_level, "Set Security Level", "Changes the security level. Announcement only, i.e. setting to Delta won't activate nuke", R_ADMIN)
	var/level = tgui_input_list(usr, "Select Security Level:", "Set Security Level", SSsecurity_level.available_levels)
	if(!level)
		return

	SSsecurity_level.set_level(level)
	log_admin("[key_name(usr)] changed the security level to [level]")
	message_admins("[key_name_admin(usr)] changed the security level to [level]")

ADMIN_VERB(events, run_weather, "Run Weather", "Triggers a weather on the specified z-level", R_FUN)
	var/weather_type = input(usr, "Choose a weather", "Weather")  as null|anything in sort_list(subtypesof(/datum/weather), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!weather_type)
		return

	var/turf/T = get_turf(usr)
	var/z_level = input(usr, "Z-Level to target?", "Z-Level", T?.z) as num|null
	if(!isnum(z_level))
		return

	SSweather.run_weather(weather_type, z_level)
	message_admins("[key_name_admin(usr)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(usr)] started weather of type [weather_type] on the z-level [z_level].")

ADMIN_VERB(events, add_mob_ability, "Add Mob Ability", "Adds an ability to a marked mob", R_FUN)
	var/datum/admins/holder = usr.client.holder
	if(!isliving(holder.marked_datum))
		to_chat(usr, span_warning("Error: Please mark a mob to add actions to it."))
		return

	var/mob/living/marked_mob = holder.marked_datum

	var/list/all_mob_actions = sort_list(subtypesof(/datum/action/cooldown/mob_cooldown), GLOBAL_PROC_REF(cmp_typepaths_asc))

	var/ability_type = tgui_input_list(usr, "Choose an ability", "Ability", all_mob_actions)

	if(!ability_type)
		return

	var/datum/action/cooldown/mob_cooldown/add_ability

	var/make_sequence = tgui_alert(usr, "Would you like this action to be a sequence of multiple abilities?", "Sequence Ability", list("Yes", "No"))
	if(make_sequence == "Yes")
		add_ability = new /datum/action/cooldown/mob_cooldown(marked_mob)
		add_ability.sequence_actions = list()
		while(!isnull(ability_type))
			var/ability_delay = tgui_input_number(usr, "Enter the delay in seconds before the next ability in the sequence is used", "Ability Delay", 2)
			if(isnull(ability_delay) || ability_delay < 0)
				ability_delay = 0
			add_ability.sequence_actions[ability_type] = ability_delay * 1 SECONDS
			ability_type = tgui_input_list(usr, "Choose a new sequence ability", "Sequence Ability", all_mob_actions)
		var/ability_cooldown = tgui_input_number(usr, "Enter the sequence abilities cooldown in seconds", "Ability Cooldown", 2)
		if(isnull(ability_cooldown) || ability_cooldown < 0)
			ability_cooldown = 2
		add_ability.cooldown_time = ability_cooldown * 1 SECONDS
		var/ability_melee_cooldown = tgui_input_number(usr, "Enter the abilities melee cooldown in seconds", "Melee Cooldown", 2)
		if(isnull(ability_melee_cooldown) || ability_melee_cooldown < 0)
			ability_melee_cooldown = 2
		add_ability.melee_cooldown_time = ability_melee_cooldown * 1 SECONDS
		add_ability.name = tgui_input_text(usr, "Choose ability name", "Ability name", "Generic Ability")
		add_ability.create_sequence_actions()
	else
		add_ability = new ability_type(marked_mob)

	if(isnull(marked_mob))
		return
	add_ability.Grant(marked_mob)

	message_admins("[key_name_admin(usr)] added mob ability [ability_type] to mob [marked_mob].")
	log_admin("[key_name(usr)] added mob ability [ability_type] to mob [marked_mob].")

ADMIN_VERB(events, remove_mob_ability, "Remove Mob Ability", "Removes an ability from the marked mob", R_FUN)
	var/datum/admins/holder = usr.client.holder
	if(!isliving(holder.marked_datum))
		to_chat(usr, span_warning("Error: Please mark a mob to remove actions from it."))
		return

	var/mob/living/marked_mob = holder.marked_datum

	var/list/all_mob_actions = list()
	for(var/datum/action/cooldown/mob_cooldown/ability in marked_mob.actions)
		all_mob_actions.Add(ability)

	var/datum/action/cooldown/mob_cooldown/ability = tgui_input_list(usr, "Remove an ability", "Ability", all_mob_actions)

	if(!ability)
		return

	var/ability_name = ability.name
	QDEL_NULL(ability)

	message_admins("[key_name_admin(usr)] removed ability [ability_name] from mob [marked_mob].")
	log_admin("[key_name(usr)] removed mob ability [ability_name] from mob [marked_mob].")

ADMIN_VERB(events, command_report_footnote, "Command Report Footnote", "Adds a footnote to the roundstart command report", R_ADMIN)
	var/datum/command_footnote/command_report_footnote = new /datum/command_footnote()
	SScommunications.block_command_report++ //Add a blocking condition to the counter until the inputs are done.

	command_report_footnote.message = tgui_input_text(usr, "This message will be attached to the bottom of the roundstart threat report. Be sure to delay the roundstart report if you need extra time.", "P.S.")
	if(!command_report_footnote.message)
		SScommunications.block_command_report--
		return

	command_report_footnote.signature = tgui_input_text(usr, "Whose signature will appear on this footnote?", "Also sign here, here, aaand here.")
	if(!command_report_footnote.signature)
		command_report_footnote.signature = "Classified"

	message_admins("[usr] has added a footnote to the command report: [command_report_footnote.message], signed [command_report_footnote.signature]")
	SScommunications.command_report_footnotes += command_report_footnote
	SScommunications.block_command_report--

/datum/command_footnote
	var/message
	var/signature

ADMIN_VERB(events, delay_command_report, "Delay Command Report", "Prevents the roundstart command report from being sent until toggled", R_ADMIN)
	if(SScommunications.block_command_report) //If it's anything other than 0, decrease. If 0, increase.
		SScommunications.block_command_report--
		message_admins("[key_name_admin(usr)] has enabled the roundstart command report.")
	else
		SScommunications.block_command_report++
		message_admins("[key_name_admin(usr)] has delayed the roundstart command report.")
