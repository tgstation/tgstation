/// Default master server machine state. Use a special screwdriver to get to the next state.
#define HDD_PANEL_CLOSED 0
/// Front master server HDD panel has been removed. Use a special crowbar to get to the next state.
#define HDD_PANEL_OPEN 1
/// Master server HDD has been pried loose and is held in by only cables. Use a special set of wirecutters to finish stealing the objective.
#define HDD_PRIED 2
/// Master server HDD has been cut loose.
#define HDD_CUT_LOOSE 3
/// The ninja has blown the HDD up.
#define HDD_OVERLOADED 4

#define SERVER_NOMINAL_TEXT "<font color='lightgreen'>Nominal</font>"

/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	base_icon_state = "RD-server"
	circuit = /obj/item/circuitboard/machine/rdserver
	req_access = list(ACCESS_RD)

	/// if TRUE, we are currently operational and giving out research points.
	var/working = TRUE
	/// if TRUE, someone manually disabled us via console.
	var/research_disabled = FALSE

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		stored_research = new /datum/techweb
	stored_research.techweb_servers |= src
	name += " [num2hex(rand(1,65535), -1)]" //gives us a random four-digit hex number as part of the name. Y'know, for fluff.

/obj/machinery/rnd/server/Destroy()
	if(stored_research)
		stored_research.techweb_servers -= src
	if(CONFIG_GET(flag/no_default_techweb_link))
		QDEL_NULL(stored_research)
	return ..()

/obj/machinery/rnd/server/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]-off"
	else
		// "working" will cover EMP'd, disabled, or just broken
		icon_state = "[base_icon_state]-[working ? "on" : "halt"]"
	return ..()

/obj/machinery/rnd/server/power_change()
	refresh_working()
	return ..()

/obj/machinery/rnd/server/on_set_machine_stat()
	refresh_working()
	return ..()

/// Checks if we should be working or not, and updates accordingly.
/obj/machinery/rnd/server/proc/refresh_working()
	if(machine_stat & (NOPOWER|EMPED) || research_disabled)
		working = FALSE
	else
		working = TRUE

	update_current_power_usage()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/rnd/server/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_machine_stat(machine_stat | EMPED)
	addtimer(CALLBACK(src, PROC_REF(fix_emp)), 60 SECONDS)
	refresh_working()

/// Callback to un-emp the server afetr some time.
/obj/machinery/rnd/server/proc/fix_emp()
	set_machine_stat(machine_stat & ~EMPED)
	refresh_working()

/// Toggles whether or not researched_disabled is, yknow, disabled
/obj/machinery/rnd/server/proc/toggle_disable(mob/user)
	research_disabled = !research_disabled
	user.log_message("[research_disabled ? "shut off" : "turned on"] [src]", LOG_GAME)
	refresh_working()

/// Gets status text based on this server's status for the computer.
/obj/machinery/rnd/server/proc/get_status_text()
	if(machine_stat & EMPED)
		return "<font color=red>O&F@I*$ - R3*&O$T R@U!R%D</font>"
	else if(machine_stat & NOPOWER)
		return "<font color=red>Offline - Server Unpowered</font>"
	else if(research_disabled)
		return "<font color=red>Offline - Server Control Disabled</font>"
	else if(!working)
		// If, for some reason, working is FALSE even though we're not emp'd or powerless,
		// We need something to update our working state - such as rebooting the server
		return "<font color=red>Offline - Reboot Required</font>"

	return SERVER_NOMINAL_TEXT

/obj/machinery/rnd/server/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!stored_research)
		return
	tool.buffer = stored_research
	to_chat(user, span_notice("Stored [src]'s techweb information in [tool]."))
	return TRUE

/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/rdservercontrol
	req_access = list(ACCESS_RD)
	var/list/servers = list()
	///Connected techweb node the server is connected to.
	var/datum/techweb/stored_research

/obj/machinery/computer/rdservercontrol/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		stored_research = SSresearch.science_tech

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	if (href_list["toggle"])
		if(allowed(usr) || obj_flags & EMAGGED)
			var/obj/machinery/rnd/server/S = locate(href_list["toggle"]) in stored_research.techweb_servers
			S.toggle_disable(usr)
		else
			to_chat(usr, span_danger("Access Denied."))

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user)
	. = ..()
	var/list/dat = list()

	dat += "<b>Connected Servers:</b>"
	dat += "<table><tr><td style='width:25%'><b>Server</b></td><td style='width:25%'><b>Status</b></td><td style='width:25%'><b>Control</b></td>"
	for(var/obj/machinery/rnd/server/server as anything in stored_research.techweb_servers)
		var/server_info = ""

		var/status_text = server.get_status_text()
		var/disable_text = server.research_disabled ? "<font color=red>Disabled</font>" : "<font color=lightgreen>Online</font>"

		server_info += "<tr><td style='width:25%'>[server.name]</td>"
		server_info += "<td style='width:25%'>[status_text]</td>"
		server_info += "<td style='width:25%'><a href='?src=[REF(src)];toggle=[REF(server)]'>([disable_text])</a></td><br>"

		dat += server_info

	dat += "</table></br>"

	dat += "<b>Research Log</b></br>"
	if(stored_research && length(stored_research.research_logs))
		dat += "<table BORDER=\"1\">"
		dat += "<tr><td><b>Entry</b></td><td><b>Research Name</b></td><td><b>Cost</b></td><td><b>Researcher Name</b></td><td><b>Console Location</b></td></tr>"
		for(var/i = stored_research.research_logs.len, i>0, i--)
			dat += "<tr><td>[i]</td>"
			for(var/j in stored_research.research_logs[i])
				dat += "<td>[j]</td>"
			dat +="</tr>"
		dat += "</table>"

	else
		dat += "</br>No history found."

	var/datum/browser/popup = new(user, "server_com", src.name, 900, 620)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/rdservercontrol/attackby(obj/item/D, mob/user, params)
	. = ..()
	src.updateUsrDialog()

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You disable the security protocols."))

/// Master R&D server. As long as this still exists and still holds the HDD for the theft objective, research points generate at normal speed. Destroy it or an antag steals the HDD? Half research speed.
/obj/machinery/rnd/server/master
	max_integrity = 1800 //takes roughly ~15s longer to break then full deconstruction.
	circuit = null
	var/obj/item/computer_disk/hdd_theft/source_code_hdd
	var/deconstruction_state = HDD_PANEL_CLOSED
	var/front_panel_screws = 4
	var/hdd_wires = 6

/obj/machinery/rnd/server/master/Initialize(mapload)
	. = ..()
	name = "\improper Master " + name
	desc += "\nIt looks incredibly resistant to damage!"
	source_code_hdd = new(src)

	add_overlay("RD-server-objective-stripes")

/obj/machinery/rnd/server/master/Destroy()
	if (source_code_hdd && (deconstruction_state == HDD_OVERLOADED))
		QDEL_NULL(source_code_hdd)

	return ..()

/obj/machinery/rnd/server/master/get_status_text()
	. = ..()
	// Give us a special message if we're nominal, but our hard drive is gone
	if(. == SERVER_NOMINAL_TEXT && !source_code_hdd)
		return "<font color=orange>Nominal - Hard Drive Missing</font>"

/obj/machinery/rnd/server/master/examine(mob/user)
	. = ..()

	switch(deconstruction_state)
		if(HDD_PANEL_CLOSED)
			. += "The front panel is closed. You can see some recesses which may have <b>screws</b>."
		if(HDD_PANEL_OPEN)
			. += "The front panel is dangling open. The hdd is in a secure housing. Looks like you'll have to <b>pry</b> it loose."
		if(HDD_PRIED)
			. += "The front panel is dangling open. The hdd has been pried from its housing. It is still connected by <b>wires</b>."
		if(HDD_CUT_LOOSE)
			. += "The front panel is dangling open. All you can see inside are cut wires and mangled metal."
		if(HDD_OVERLOADED)
			. += "The front panel is dangling open. The hdd inside is destroyed and the wires are all burned."

/obj/machinery/rnd/server/master/tool_act(mob/living/user, obj/item/tool, tool_type)
	// Only antags are given the training and knowledge to disassemble this thing.
	if(is_special_character(user))
		return ..()

	if(user.combat_mode)
		return FALSE

	balloon_alert(user, "you can't find an obvious maintenance hatch!")
	return TRUE

/obj/machinery/rnd/server/master/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/computer_disk/hdd_theft))
		switch(deconstruction_state)
			if(HDD_PANEL_CLOSED)
				balloon_alert(user, "you can't find a place to insert it!")
				return TRUE
			if(HDD_PANEL_OPEN)
				balloon_alert(user, "you weren't trained to install this!")
				return TRUE
			if(HDD_PRIED)
				balloon_alert(user, "the hdd housing is completely broken, it won't fit!")
				return TRUE
			if(HDD_CUT_LOOSE)
				balloon_alert(user, "the hdd housing is completely broken and all the wires are cut!")
				return TRUE
			if(HDD_OVERLOADED)
				balloon_alert(user, "the inside is scorched and all the wires are burned!")
				return TRUE
	return ..()

/obj/machinery/rnd/server/master/screwdriver_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_CLOSED || user.combat_mode)
		return FALSE

	to_chat(user, span_notice("You can see [front_panel_screws] screw\s. You start unscrewing [front_panel_screws == 1 ? "it" : "them"]..."))
	while(tool.use_tool(src, user, 7.5 SECONDS, volume=100))
		front_panel_screws--

		if(front_panel_screws <= 0)
			deconstruction_state = HDD_PANEL_OPEN
			to_chat(user, span_notice("You remove the last screw from [src]'s front panel."))
			add_overlay("RD-server-hdd-panel-open")
			return TRUE
		to_chat(user, span_notice("The screw breaks as you remove it. Only [front_panel_screws] left..."))
	return TRUE

/obj/machinery/rnd/server/master/crowbar_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PANEL_OPEN || user.combat_mode)
		return FALSE

	to_chat(user, span_notice("You can see [source_code_hdd] in a secure housing behind the front panel. You begin to pry it loose..."))
	if(tool.use_tool(src, user, 15 SECONDS, volume=100))
		to_chat(user, span_notice("You destroy the housing, prying [source_code_hdd] free."))
		deconstruction_state = HDD_PRIED
	return TRUE

/obj/machinery/rnd/server/master/wirecutter_act(mob/living/user, obj/item/tool)
	if(deconstruction_state != HDD_PRIED || user.combat_mode)
		return FALSE

	to_chat(user, span_notice("There are [hdd_wires] wire\s connected to [source_code_hdd]. You start cutting [hdd_wires == 1 ? "it" : "them"]..."))
	while(tool.use_tool(src, user, 7.5 SECONDS, volume=100))
		hdd_wires--

		if(hdd_wires <= 0)
			deconstruction_state = HDD_CUT_LOOSE
			to_chat(user, span_notice("You cut the final wire and remove [source_code_hdd]."))
			try_put_in_hand(source_code_hdd, user)
			source_code_hdd = null
			stored_research.income_modifier *= 0.5
			return TRUE
		to_chat(user, span_notice("You delicately cut the wire. [hdd_wires] wire\s left..."))
	return TRUE

/obj/machinery/rnd/server/master/on_deconstruction()
	// If the machine contains a source code HDD, destroying it will negatively impact research speed. Safest to log this.
	if(source_code_hdd)
		// If there's a usr, this was likely a direct deconstruction of some sort. Extra logging info!
		if(usr)
			var/mob/user = usr

			message_admins("[ADMIN_LOOKUPFLW(user)] deconstructed [ADMIN_JMP(src)].")
			user.log_message("deconstructed [src].", LOG_GAME)
			return ..()

		message_admins("[ADMIN_JMP(src)] has been deconstructed by an unknown user.")
		log_game("[src] has been deconstructed by an unknown user.")

	return ..()

/// Destroys the source_code_hdd if present and sets the machine state to overloaded, adding the panel open overlay if necessary.
/obj/machinery/rnd/server/master/proc/overload_source_code_hdd()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)

	if(deconstruction_state == HDD_PANEL_CLOSED)
		add_overlay("RD-server-hdd-panel-open")

	front_panel_screws = 0
	hdd_wires = 0
	deconstruction_state = HDD_OVERLOADED

#undef HDD_PANEL_CLOSED
#undef HDD_PANEL_OPEN
#undef HDD_PRIED
#undef HDD_CUT_LOOSE
