SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	/// Currently set security level
	var/current_level = SEC_LEVEL_GREEN

/**
 * Sets a new security level as our current level
 *
 * Arguments:
 * * new_level The new security level that will become our current level
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level)
	SSsecurity_level.current_level = new_level
	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, new_level)
	SSnightshift.check_nightshift()
	SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
