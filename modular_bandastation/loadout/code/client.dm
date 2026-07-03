/client
	/// Call `proc/get_donator_level()` instead to get a value when possible.
	var/donator_level = BASIC_DONATOR_LEVEL

// For unit-tests
/datum/client_interface
	var/donator_level = BASIC_DONATOR_LEVEL

/datum/client_interface/proc/get_donator_level()
	return donator_level

/client/proc/get_donator_level()
	if(CONFIG_GET(flag/enable_localhost_rank) && is_localhost())
		return CONFIG_GET(number/localhost_donate_tier)
	return max(donator_level, get_donator_level_from_admin())

/client/proc/get_donator_level_from_admin()
	var/rank_flags = get_player_admin_flags(src)
	if(!rank_flags)
		return BASIC_DONATOR_LEVEL
	if(rank_flags & R_EVERYTHING)
		return MAX_DONATOR_LEVEL
	if(rank_flags & R_ADMIN)
		return ADMIN_DONATOR_LEVEL
	return BASIC_DONATOR_LEVEL
