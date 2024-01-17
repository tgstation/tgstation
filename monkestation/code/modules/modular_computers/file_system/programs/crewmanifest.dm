/datum/computer_file/program/crew_manifest
	transfer_access = list()
	detomatix_resistance = NONE

/datum/computer_file/program/crew_manifest/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(_update_ui_data))

/datum/computer_file/program/crew_manifest/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/computer_file/program/crew_manifest/proc/_update_ui_data()
	SIGNAL_HANDLER
	update_static_data_for_all_viewers()
