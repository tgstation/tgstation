///Data holder for the announcers that can be used in a game, this can be used to have alternative announcements outside of the default e.g.the intern
/datum/centcom_announcer
	///Roundshift start audio
	var/welcome_sounds = list()
	///Sounds made when announcement is receivedc
	var/alert_sounds = list()
	///Sounds made when command report is received
	var/command_report_sounds = list()
	///Event audio, can be used for specific event announcements and is assoc key - sound. If no sound is found the default is used.area
	var/event_sounds = list()
	///Override this to have a custom message to show instead of the normal priority announcement
	var/custom_alert_message


/datum/centcom_announcer/proc/get_rand_welcome_sound()
	return pick(welcome_sounds)


/datum/centcom_announcer/proc/get_rand_alert_sound()
	return pick(alert_sounds)

/datum/centcom_announcer/proc/get_rand_report_sound()
	return pick(command_report_sounds)
