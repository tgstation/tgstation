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

	///The headset that we use for broadcasting
	var/obj/item/radio/headset/radio
	///The message that we send when someone is joining.
	var/arrival = "%PERSON has signed up as %RANK"
	///Whether the arrival message is sent
	var/arrival_toggle = TRUE
	///The message that we send when a department head arrives.
	var/newhead = "%PERSON, %RANK, is the department head."
	///Whether the newhead message is sent.
	var/newhead_toggle = TRUE

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

	///If true, researched nodes will be announced to the appropriate channels
	var/announce_research_node = TRUE
	/// The text that we send when announcing researched nodes.
	var/node_message = "The %NODE techweb node has been researched"

/obj/machinery/announcement_system/Initialize(mapload)
	. = ..()
	GLOB.announcement_systems += src
	radio = new /obj/item/radio/headset/silicon/ai(src)
	update_appearance()

/obj/machinery/announcement_system/randomize_language_if_on_station()
	return

/obj/machinery/announcement_system/update_icon_state()
	icon_state = "[base_icon_state]_[is_operational ? "On" : "Off"][panel_open ? "_Open" : null]"
	return ..()

/obj/machinery/announcement_system/update_overlays()
	. = ..()
	if(arrival_toggle)
		. += greenlight

	if(newhead_toggle)
		. += pinklight

	if(machine_stat & BROKEN)
		. += errorlight

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
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

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/machinery/announcement_system/proc/announce(message_type, target, rank, list/channels)
	if(!is_operational)
		return

	var/message

	switch(message_type)
		if(AUTO_ANNOUNCE_ARRIVAL)
			if(!arrival_toggle)
				return
			message = CompileText(arrival, target, rank)
		if(AUTO_ANNOUNCE_NEWHEAD)
			if(!newhead_toggle)
				return
			message = CompileText(newhead, target, rank)
		if(AUTO_ANNOUNCE_ARRIVALS_BROKEN)
			message = "The arrivals shuttle has been damaged. Docking for repairs..."
		if(AUTO_ANNOUNCE_NODE)
			message = replacetext(node_message, "%NODE", target)

	broadcast(message, channels)

/// Announces a new security officer joining over the radio
/obj/machinery/announcement_system/proc/announce_officer(mob/officer, department)
	if (!is_operational)
		return

	broadcast("Officer [officer.real_name] has been assigned to [department].", list(RADIO_CHANNEL_SECURITY))

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
	var/list/data = list()
	data["arrival"] = arrival
	data["arrivalToggle"] = arrival_toggle
	data["newhead"] = newhead
	data["newheadToggle"] = newhead_toggle
	data["node_message"] = node_message
	data["node_toggle"] = announce_research_node
	return data

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
	switch(action)
		if("ArrivalText")
			var/new_message = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				arrival = new_message
				usr.log_message("updated the arrivals announcement to: [new_message]", LOG_GAME)
		if("NewheadText")
			var/new_message = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				newhead = new_message
				usr.log_message("updated the head announcement to: [new_message]", LOG_GAME)
		if("node_message")
			var/new_message = trim(html_encode(param["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				node_message = new_message
				usr.log_message("updated the researched node announcement to: [node_message]", LOG_GAME)
		if("newhead_toggle")
			newhead_toggle = !newhead_toggle
			update_appearance()
		if("arrivalToggle")
			arrival_toggle = !arrival_toggle
			update_appearance()
		if("node_toggle")
			announce_research_node = !announce_research_node
	add_fingerprint(usr)

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

	arrival = pick("#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!", "CRITICAL ERROR 99.", "ERR)#: DA#AB@#E NOT F(*ND!")
	newhead = pick("OV#RL()D: \[UNKNOWN??\] DET*#CT)D!", "ER)#R - B*@ TEXT F*O(ND!", "AAS.exe is not responding. NanoOS is searching for a solution to the problem.")
	node_message = pick(list(
		replacetext(/obj/machinery/announcement_system::node_message, "%NODE", /datum/techweb_node/mech_clown::display_name),
		"R/NT1M3 A= ANNOUN-*#nt_SY!?EM.dm, LI%£ 86: N=0DE NULL!",
		"BEPIS BEPIS BEPIS",
	))

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
