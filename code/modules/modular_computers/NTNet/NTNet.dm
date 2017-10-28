GLOBAL_DATUM_INIT(ntnet_global, /datum/ntnet, new)


// This is the NTNet datum. There can be only one NTNet datum in game at once. Modular computers read data from this.
/datum/ntnet
	var/list/relays = list()
	var/list/logs = list()
	var/list/available_station_software = list()
	var/list/available_antag_software = list()
	var/list/chat_channels = list()
	var/list/fileservers = list()
	// Amount of logs the system tries to keep in memory. Keep below 999 to prevent byond from acting weirdly.
	// High values make displaying logs much laggier.
	var/setting_maxlogcount = 100

	// These only affect wireless. LAN (consoles) are unaffected since it would be possible to create scenario where someone turns off NTNet, and is unable to turn it back on since it refuses connections
	var/setting_softwaredownload = 1
	var/setting_peertopeer = 1
	var/setting_communication = 1
	var/setting_systemcontrol = 1
	var/setting_disabled = 0					// Setting to 1 will disable all wireless, independently on relays status.

	var/intrusion_detection_enabled = 1 		// Whether the IDS warning system is enabled
	var/intrusion_detection_alarm = 0			// Set when there is an IDS warning due to malicious (antag) software.


// If new NTNet datum is spawned, it replaces the old one.
/datum/ntnet/New()
	if(GLOB.ntnet_global && (GLOB.ntnet_global != src))
		GLOB.ntnet_global = src // There can be only one.
	for(var/obj/machinery/ntnet_relay/R in GLOB.machines)
		relays.Add(R)
		R.NTNet = src
	build_software_lists()
	add_log("NTNet logging system activated.")

// Simplified logging: Adds a log. log_string is mandatory parameter, source is optional.
/datum/ntnet/proc/add_log(log_string, obj/item/computer_hardware/network_card/source = null)
	var/log_text = "[worldtime2text()] - "
	if(source)
		log_text += "[source.get_network_tag()] - "
	else
		log_text += "*SYSTEM* - "
	log_text += log_string
	logs.Add(log_text)


	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len-setting_maxlogcount,0)


// Checks whether NTNet operates. If parameter is passed checks whether specific function is enabled.
/datum/ntnet/proc/check_function(specific_action = 0)
	if(!relays || !relays.len) // No relays found. NTNet is down
		return FALSE

	var/operating = FALSE

	// Check all relays. If we have at least one working relay, network is up.
	for(var/M in relays)
		var/obj/machinery/ntnet_relay/R = M
		if(R.is_operational())
			operating = TRUE
			break

	if(setting_disabled)
		return FALSE

	switch(specific_action)
		if(NTNET_SOFTWAREDOWNLOAD)
			return (operating && setting_softwaredownload)
		if(NTNET_PEERTOPEER)
			return (operating && setting_peertopeer)
		if(NTNET_COMMUNICATION)
			return (operating && setting_communication)
		if(NTNET_SYSTEMCONTROL)
			return (operating && setting_systemcontrol)
	return operating

// Builds lists that contain downloadable software.
/datum/ntnet/proc/build_software_lists()
	available_station_software = list()
	available_antag_software = list()
	for(var/F in typesof(/datum/computer_file/program))
		var/datum/computer_file/program/prog = new F
		// Invalid type (shouldn't be possible but just in case), invalid filetype (not executable program) or invalid filename (unset program)
		if(!prog || prog.filename == "UnknownProgram" || prog.filetype != "PRG")
			continue
		// Check whether the program should be available for station/antag download, if yes, add it to lists.
		if(prog.available_on_ntnet)
			available_station_software.Add(prog)
		if(prog.available_on_syndinet)
			available_antag_software.Add(prog)

// Attempts to find a downloadable file according to filename var
/datum/ntnet/proc/find_ntnet_file_by_name(filename)
	for(var/N in available_station_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P
	for(var/N in available_antag_software)
		var/datum/computer_file/program/P = N
		if(filename == P.filename)
			return P

// Resets the IDS alarm
/datum/ntnet/proc/resetIDS()
	intrusion_detection_alarm = 0

/datum/ntnet/proc/toggleIDS()
	resetIDS()
	intrusion_detection_enabled = !intrusion_detection_enabled

// Removes all logs
/datum/ntnet/proc/purge_logs()
	logs = list()
	add_log("-!- LOGS DELETED BY SYSTEM OPERATOR -!-")

// Updates maximal amount of stored logs. Use this instead of setting the number, it performs required checks.
/datum/ntnet/proc/update_max_log_count(lognumber)
	if(!lognumber)
		return FALSE
	// Trim the value if necessary
	lognumber = max(MIN_NTNET_LOGS, min(lognumber, MAX_NTNET_LOGS))
	setting_maxlogcount = lognumber
	add_log("Configuration Updated. Now keeping [setting_maxlogcount] logs in system memory.")

/datum/ntnet/proc/toggle_function(function)
	if(!function)
		return
	function = text2num(function)
	switch(function)
		if(NTNET_SOFTWAREDOWNLOAD)
			setting_softwaredownload = !setting_softwaredownload
			add_log("Configuration Updated. Wireless network firewall now [setting_softwaredownload ? "allows" : "disallows"] connection to software repositories.")
		if(NTNET_PEERTOPEER)
			setting_peertopeer = !setting_peertopeer
			add_log("Configuration Updated. Wireless network firewall now [setting_peertopeer ? "allows" : "disallows"] peer to peer network traffic.")
		if(NTNET_COMMUNICATION)
			setting_communication = !setting_communication
			add_log("Configuration Updated. Wireless network firewall now [setting_communication ? "allows" : "disallows"] instant messaging and similar communication services.")
		if(NTNET_SYSTEMCONTROL)
			setting_systemcontrol = !setting_systemcontrol
			add_log("Configuration Updated. Wireless network firewall now [setting_systemcontrol ? "allows" : "disallows"] remote control of station's systems.")
