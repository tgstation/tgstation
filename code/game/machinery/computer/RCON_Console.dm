// RCON REMOTE CONTROL CONSOLE
//
// Last Change 1.1.2015 by Atlantis
//
// Allows remote operation of electrical systems on station (SMESs and Breaker Boxes)

/obj/machinery/computer/rcon
	name = "\improper RCON console"
	desc = "Console used to remotely control machinery on the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	circuit = /obj/item/weapon/circuitboard/rcon_console
	req_one_access = list(access_engine)
	var/current_tag = null

	var/list/known_SMESs = null
	var/list/known_breakers = null
	// Allows you to hide specific parts of the UI
	var/hide_SMES = 0
	var/hide_SMES_details = 0
	var/hide_breakers = 0

// Proc: attack_hand()
// Parameters: 1 (user - Person which clicked this computer)
// Description: Opens UI of this machine.
/obj/machinery/computer/rcon/attack_hand(var/mob/user as mob)
	if(..())
		return
	if (src.allowed(user))
		ui_interact(user)
	else
		user << "<span class='danger'>Access denied.</span>"

// Proc: ui_interact()
// Parameters: 4 (standard NanoUI parameters)
// Description: Uses dark magic (NanoUI) to render this machine's UI
/obj/machinery/computer/rcon/ui_interact(mob/user, ui_key = "rcon", var/datum/nanoui/ui = null, force_open=1)
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "rcon.tmpl", "RCON Console", 600, 400, force_open)

// Proc: Topic()
// Parameters: 2 (href, href_list - allows us to process UI clicks)
// Description: Allows us to process UI clicks, which are relayed in form of hrefs.
/obj/machinery/computer/rcon/Topic(href, href_list)
	if(..())
		return

	if(href_list["smes_in_toggle"])
		var/obj/machinery/power/smes/SMES = GetSMESByTag(href_list["smes_in_toggle"])
		if(SMES)
			if(SMES.input_attempt)
				SMES.input_attempt = 0
				SMES.inputting = 0
			else
				SMES.input_attempt = 1
			SMES.update_icon()
	if(href_list["smes_out_toggle"])
		var/obj/machinery/power/smes/SMES = GetSMESByTag(href_list["smes_out_toggle"])
		if(SMES)
			if(SMES.output_attempt)
				SMES.output_attempt = 0
				SMES.outputting = 0
			else
				SMES.output_attempt = 1
			SMES.update_icon()
	if(href_list["smes_in_set"])
		var/obj/machinery/power/smes/SMES = GetSMESByTag(href_list["smes_in_set"])
		if(SMES)
			var/inputset = input(usr, "Enter new input level (0-[SMES.input_level_max])", "SMES Input Power Control") as num
			SMES.input_level = Clamp(inputset, 0, SMES.input_level_max)
		SMES.update_icon()
	if(href_list["smes_out_set"])
		var/obj/machinery/power/smes/SMES = GetSMESByTag(href_list["smes_out_set"])
		if(SMES)
			var/outputset = input(usr, "Enter new output level (0-[SMES.output_level_max])", "SMES Input Power Control") as num
			SMES.output_level = Clamp(outputset, 0, SMES.output_level_max)
		SMES.update_icon()

	if(href_list["toggle_breaker"])
		var/obj/machinery/power/breakerbox/toggle = null
		for(var/obj/machinery/power/breakerbox/breaker in known_breakers)
			if(breaker.RCon_tag == href_list["toggle_breaker"])
				toggle = breaker
		if(toggle)
			if(toggle.update_locked)
				usr << "The breaker box was recently toggled. Please wait before toggling it again."
			else
				toggle.auto_toggle()
	if(href_list["hide_smes"])
		hide_SMES = !hide_SMES
	if(href_list["hide_smes_details"])
		hide_SMES_details = !hide_SMES_details
	if(href_list["hide_breakers"])
		hide_breakers = !hide_breakers


// Proc: GetSMESByTag()
// Parameters: 1 (tag - RCON tag of SMES we want to look up)
// Description: Looks up and returns SMES which has matching RCON tag
/obj/machinery/computer/rcon/proc/GetSMESByTag(var/tag)
	if(!tag)
		return

	for(var/obj/machinery/power/smes/S in known_SMESs)
		if(S.RCon_tag == tag)
			return S

// Proc: FindDevices()
// Parameters: None
// Description: Refreshes local list of known devices.
/obj/machinery/computer/rcon/proc/FindDevices()
	known_SMESs = new /list()
	for(var/obj/machinery/power/smes/SMES in machines)
		if(SMES.RCon_tag && (SMES.RCon_tag != "NO_TAG"))
			known_SMESs.Add(SMES)

	known_breakers = new /list()
	for(var/obj/machinery/power/breakerbox/breaker in machines)
		if(breaker.RCon_tag && (breaker.RCon_tag != "NO_TAG"))
			known_breakers.Add(breaker)

/obj/machinery/computer/rcon/get_ui_data()
	FindDevices() // Update our devices list
	var/data = list()

	// SMES DATA (simplified view)
	var/list/smeslist[0]
	for(var/obj/machinery/power/smes/SMES in known_SMESs)
		smeslist.Add(list(list(
		"charge" = round(100*(SMES.charge/SMES.capacity)),	//Would round this to 1 decimal place but that doesn't work for some reason
		"input_set" = SMES.input_attempt,
		"input_val" = round(SMES.input_level),
		"output_set" = SMES.output_attempt,
		"output_val" = round(SMES.output_level),
		"output_load" = round(SMES.output_shown),
		"RCON_tag" = SMES.RCon_tag
		)))

	data["smes_info"] = sortByKey(smeslist, "RCON_tag")

	// BREAKER DATA (simplified view)
	var/list/breakerlist[0]
	for(var/obj/machinery/power/breakerbox/BR in known_breakers)
		breakerlist.Add(list(list(
		"RCON_tag" = BR.RCon_tag,
		"enabled" = BR.on
		)))

	data["breaker_info"] = sortByKey(breakerlist, "RCON_tag")

	data["hide_smes"] = hide_SMES
	data["hide_smes_details"] = hide_SMES_details
	data["hide_breakers"] = hide_breakers

	return data