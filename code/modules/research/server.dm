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

#define SERVER_NOMINAL_TEXT "Nominal"

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
	//servers handle techwebs differently as we are expected to be there to connect
	//every other machinery on-station.
	if(!stored_research)
		if(CONFIG_GET(flag/no_default_techweb_link))
			stored_research = new /datum/techweb
		else
			var/datum/techweb/science_web = locate(/datum/techweb/science) in SSresearch.techwebs
			connect_techweb(science_web)
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
		return "O&F@I*$ - R3*&O$T R@U!R%D"
	else if(machine_stat & NOPOWER)
		return "Offline - Server Unpowered"
	else if(research_disabled)
		return "Offline - Server Control Disabled"
	else if(!working)
		// If, for some reason, working is FALSE even though we're not emp'd or powerless,
		// We need something to update our working state - such as rebooting the server
		return "Offline - Reboot Required"

	return SERVER_NOMINAL_TEXT

/obj/machinery/rnd/server/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!stored_research)
		return
	tool.set_buffer(stored_research)
	balloon_alert(user, "saved to multitool buffer")
	return TRUE

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

/obj/machinery/rnd/server/master/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
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
		// Destroyed with a hard drive inside = harm income
		stored_research.income_modifier *= 0.5
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
		// Overloaded = harm income
		stored_research.income_modifier *= 0.5

	if(deconstruction_state == HDD_PANEL_CLOSED)
		add_overlay("RD-server-hdd-panel-open")

	front_panel_screws = 0
	hdd_wires = 0
	deconstruction_state = HDD_OVERLOADED

#undef HDD_CUT_LOOSE
#undef HDD_OVERLOADED
#undef HDD_PANEL_CLOSED
#undef HDD_PANEL_OPEN
#undef HDD_PRIED
#undef SERVER_NOMINAL_TEXT
