GLOBAL_LIST_EMPTY(announcement_systems)

/obj/machinery/announcement_system
	density = TRUE
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "AAS_On"
	base_icon_state = "AAS"

	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.05

	circuit = /obj/item/circuitboard/machine/announcement_system

	///All possible announcements and their local configurations
	var/list/datum/aas_config_entry/config_entries = list()

	///The headset that we use for broadcasting
	var/obj/item/radio/headset/radio

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/Initialize(mapload)
	. = ..()
	GLOB.announcement_systems += src
	radio = new /obj/item/radio/headset/silicon/ai(src)
	config_entries = init_subtypes(/datum/aas_config_entry, list())
	update_appearance()

/obj/machinery/announcement_system/randomize_language_if_on_station()
	return

/obj/machinery/announcement_system/update_icon_state()
	icon_state = "[base_icon_state]_[is_operational ? "On" : "Off"][panel_open ? "_Open" : null]"
	return ..()

/obj/machinery/announcement_system/update_overlays()
	. = ..()
	if((locate(/datum/aas_config_entry/arrival) in config_entries)?.enabled)
		. += greenlight

	if((locate(/datum/aas_config_entry/newhead) in config_entries)?.enabled)
		. += pinklight

	if(machine_stat & BROKEN)
		. += errorlight

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
	QDEL_LIST(config_entries)
	GLOB.announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	toggle_panel_open()
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance hatch of [src]."))
	update_appearance()
	return TRUE

/obj/machinery/announcement_system/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/announcement_system/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open || !(machine_stat & BROKEN))
		return FALSE
	to_chat(user, span_notice("You reset [src]'s firmware."))
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()

/// Sends a message to the appropriate channels.
/obj/machinery/announcement_system/proc/broadcast(message, list/channels)
	use_energy(active_power_usage)
	if(channels.len == 0)
		radio.talk_into(src, message, null)
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel)

/obj/machinery/announcement_system/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutomatedAnnouncement")
		ui.open()

/obj/machinery/announcement_system/ui_data()
	var/list/configs = list()
	for(var/datum/aas_config_entry/config in config_entries)
		configs += list(list(
			name = config.name,
			entryRef = REF(config),
			enabled = config.enabled,
			modifiable = config.modifiable,
			announcementLinesMap = config.announcement_lines_map,
			generalTooltip = config.general_tooltip,
			varsAndTooltipsMap = config.vars_and_tooltips_map
		))
	return list("config_entries" = configs)

/obj/machinery/announcement_system/ui_act(action, param)
	. = ..()
	if(.)
		return
	if(!usr.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(machine_stat & BROKEN)
		visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
		playsound(src.loc, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
		return

	add_fingerprint(usr)
	var/datum/aas_config_entry/config = locate(param["entryRef"]) in config_entries
	if(!config || !config.modifiable)
		return

	switch(action)
		if("Toggle")
			config.enabled = !config.enabled
			if (config.type in list(/datum/aas_config_entry/arrival, /datum/aas_config_entry/newhead))
				update_appearance()
		if("Text")
			var/new_message = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				config.announcement_lines_map[param["lineKey"]] = new_message
				usr.log_message("updated [param["lineKey"]] line in the [config.name] to: [new_message]", LOG_GAME)

/obj/machinery/announcement_system/attack_robot(mob/living/silicon/user)
	. = attack_ai(user)

/obj/machinery/announcement_system/attack_ai(mob/user)
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("[src]'s firmware appears to be malfunctioning!"))
		return
	interact(user)

/obj/machinery/announcement_system/proc/act_up() //does funny breakage stuff
	if(!atom_break()) // if badmins flag this unbreakable or its already broken
		return

	for (var/datum/aas_config_entry/config in config_entries)
		config.act_up()

/obj/machinery/announcement_system/emp_act(severity)
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)) && !(. & EMP_PROTECT_SELF))
		act_up()

/obj/machinery/announcement_system/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	act_up()
	balloon_alert(user, "announcement strings corrupted")
	return TRUE

/// Announces configs entry message with the provided variables. Channels and announcement_line are optional.
/obj/machinery/announcement_system/proc/announce(aas_config_entry_type, list/variables_map, list/channels, announcement_line)
	var/msg = compile_config_message(aas_config_entry_type, variables_map, announcement_line)
	if (msg)
		broadcast(msg, channels)

/// Compiles the announcement message with the provided variables. Announcement line is optional.
/obj/machinery/announcement_system/proc/compile_config_message(aas_config_entry_type, list/variables_map, announcement_line)
	var/datum/aas_config_entry/config = locate(aas_config_entry_type) in config_entries
	if (!config)
		return
	return config.compile_announce(variables_map, announcement_line)

/// Returns a random announcement system that is operational and has the specified config entry. Config entry is optional.
/proc/get_announcement_system(aas_config_entry_type)
	if (!GLOB.announcement_systems.len)
		return null
	var/list/intact_aass = list()
	for(var/obj/machinery/announcement_system/announce as anything in GLOB.announcement_systems)
		if(!QDELETED(announce) && announce.is_operational)
			if(aas_config_entry_type)
				var/datum/aas_config_entry/entry = locate(aas_config_entry_type) in announce.config_entries
				if(!entry || !entry.enabled)
					continue
			intact_aass += announce
	return intact_aass.len ? pick(intact_aass) : null

/// Announces the provided message with the provided variables and config entry type. Channels and announcement_line are optional.
/proc/aas_config_announce(aas_config_entry_type, list/variables_map, list/channels, announcement_line)
	var/obj/machinery/announcement_system/announcer = get_announcement_system(aas_config_entry_type)
	if (!announcer)
		return
	announcer.announce(aas_config_entry_type, variables_map, channels, announcement_line)

/datum/aas_config_entry
	var/name = "AAS configurable entry"
	// Should we broadcast this announcement?
	var/enabled = TRUE
	// The announcement message. Key will be displayed in the UI.
	var/list/announcement_lines_map = list("Message" = "This is a default announcement line.")
	// Goes before tooltips for vars, mainly used if announcement has no replacable vars
	var/general_tooltip
	// Contains all replacable vars and their tooltips
	var/list/vars_and_tooltips_map = list()
	// Can be changed or disabled by players
	var/modifiable = TRUE

/// Compiles the announcement message with the provided variables. Announcement line is optional.
/datum/aas_config_entry/proc/compile_announce(list/variables_map, announcement_line)
	var/announcement_message = announcement_lines_map[announcement_lines_map[1]]
	// In case of key
	if (announcement_line && (announcement_line in announcement_lines_map))
		announcement_message = announcement_lines_map[announcement_line]
	// In case of index
	else if (announcement_line && isnum(announcement_line))
		announcement_message = announcement_lines_map[announcement_lines_map[announcement_line]]
	for(var/variable in vars_and_tooltips_map)
		announcement_message = replacetext_char(announcement_message, variable, variables_map[variable] || "\[NO DATA\]")
	return announcement_message

/// Called when the announcement system is broken or EMPed.
/datum/aas_config_entry/proc/act_up()
	SHOULD_CALL_PARENT(TRUE)

	// Please do not mess with entries, that players can't fix.
	if(!modifiable)
		return TRUE
	return FALSE

/*
	Global config entries for the announcement system.
*/

/datum/aas_config_entry/arrival
	name = "Arrival Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON has signed up as %RANK")
	vars_and_tooltips_map = list(
		"%PERSON" = "will be replaced with their name.",
		"%RANK" = "with their job."
	)

/datum/aas_config_entry/arrival/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick("#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!",
		"CRITICAL ERROR 99.",
		"ERR)#: DA#AB@#E NOT F(*ND!")

/datum/aas_config_entry/newhead
	name = "Departmental Head Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON, %RANK, is the department head.")
	vars_and_tooltips_map = list(
		"%PERSON" = "will be replaced with their name.",
		"%RANK" = "with their job."
	)

/datum/aas_config_entry/newhead/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick("OV#RL()D: \[UNKNOWN??\] DET*#CT)D!",
		"ER)#R - B*@ TEXT F*O(ND!",
		"AAS.exe is not responding. NanoOS is searching for a solution to the problem.")

/datum/aas_config_entry/researched_node
	name = "Research Node Announcement"
	announcement_lines_map = list(
		"Message" = "The %NODE techweb node has been researched")
	vars_and_tooltips_map = list(
		"%NODE" = "will be replaced with the researched node."
	)

/datum/aas_config_entry/researched_node/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		replacetext(/datum/aas_config_entry/researched_node::announcement_lines_map["Message"], "%NODE", /datum/techweb_node/mech_clown::display_name),
		"R/NT1M3 A= ANNOUN-*#nt_SY!?EM.dm, LI%£ 86: N=0DE NULL!",
		"BEPIS BEPIS BEPIS",
		"ERR)#R - B*@ TEXT F*O(ND!")

/datum/aas_config_entry/arrivals_broken
	name = "Arrivals Shuttle Malfunction Announcement"
	announcement_lines_map = list(
		"Message" = "The arrivals shuttle has been damaged. Docking for repairs...")
	general_tooltip = "Broadcasted, when arrivals shuttle docks for repairs. No replacable variables provided."
	modifiable = FALSE

/datum/aas_config_entry/announce_officer
	name = "Security Officer Arrival Announcement"
	announcement_lines_map = list(
		"Message" = "Officer %OFFICER has been assigned to %DEPARTMENT.")
	vars_and_tooltips_map = list(
		"%OFFICER" = "will be replaced with the officer's name.",
		"%DEPARTMENT" = "with the department they were assigned to."
	)
	modifiable = FALSE
