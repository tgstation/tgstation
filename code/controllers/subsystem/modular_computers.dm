///The maximum amount of logs that can be generated before they start overwriting eachother.
#define MAX_LOG_COUNT 300

SUBSYSTEM_DEF(modular_computers)
	name = "Modular Computers"
	flags = SS_NO_FIRE

	///List of all ModPC logging
	var/list/logs = list()

	///List of all programs available to download from the NTNet store.
	var/list/available_station_software = list()
	///List of all programs that can be downloaded from an emagged NTNet store.
	var/list/available_antag_software = list()
	///List of all chat channels created by Chat Client.
	var/list/chat_channels = list()

	///Boolean on whether the IDS warning system is enabled
	var/intrusion_detection_enabled = TRUE
	///Boolean to show a message warning if there's an active intrusion for Wirecarp users.
	var/intrusion_detection_alarm = FALSE
	var/next_picture_id = 0

/datum/controller/subsystem/modular_computers/Initialize()
	build_software_lists()
	initialized = TRUE
	return SS_INIT_SUCCESS

///Finds all downloadable programs and adds them to their respective downloadable list.
/datum/controller/subsystem/modular_computers/proc/build_software_lists()
	for(var/datum/computer_file/program/prog as anything in subtypesof(/datum/computer_file/program))
		// Has no TGUI file so is not meant to be a downloadable thing.
		if(!initial(prog.tgui_id))
			continue
		prog = new prog

		if(prog.available_on_ntnet)
			available_station_software.Add(prog)
		if(prog.available_on_syndinet)
			available_antag_software.Add(prog)

///Attempts to find a new file through searching the available stores with its name.
/datum/controller/subsystem/modular_computers/proc/find_ntnet_file_by_name(filename)
	for(var/datum/computer_file/program/programs as anything in available_station_software + available_antag_software)
		if(filename == programs.filename)
			return programs
	return null

///Attempts to find a chatorom using the ID of the channel.
/datum/controller/subsystem/modular_computers/proc/get_chat_channel_by_id(id)
	for(var/datum/ntnet_conversation/chan as anything in chat_channels)
		if(chan.id == id)
			return chan
	return null

/**
 * Records a message into the station logging system for the network
 * Arguments:
 * * log_string - The message being logged
 */
/datum/controller/subsystem/modular_computers/proc/add_log(log_string)
	var/list/log_text = list()
	log_text += "\[[station_time_timestamp()]\]"
	log_text += "*SYSTEM* - "
	log_text += log_string
	log_string = log_text.Join()

	logs.Add(log_string)

	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > MAX_LOG_COUNT)
		logs = logs.Copy(logs.len - MAX_LOG_COUNT, 0)

/**
 * Removes all station logs and leaves it with an alert that it's been wiped.
 */
/datum/controller/subsystem/modular_computers/proc/purge_logs()
	logs = list()
	add_log("-!- LOGS DELETED BY SYSTEM OPERATOR -!-")

/**
 * Returns a name which a /datum/picture can be assigned to.
 * Use this function to get asset names and to avoid cache duplicates/overwriting.
 */
/datum/controller/subsystem/modular_computers/proc/get_next_picture_name()
	var/next_uid = next_picture_id
	next_picture_id++
	return "ntos_picture_[next_uid].png"

#undef MAX_LOG_COUNT
