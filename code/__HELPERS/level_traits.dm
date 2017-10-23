/proc/is_station_level(z)
	return SSmapping.check_level_trait(z, STATION_LEVEL)

/proc/is_station_contact(z)
	return SSmapping.check_level_trait(z, STATION_CONTACT)

/proc/is_teleport_allowed(z)
	return !SSmapping.check_level_trait(z, BLOCK_TELEPORT)

/proc/is_admin_level(z)
	return SSmapping.check_level_trait(z, ADMIN_LEVEL)

/proc/is_away_level(z)
	return SSmapping.check_level_trait(z, AWAY_LEVEL)

/proc/is_mining_level(z)
	return SSmapping.check_level_trait(z, ORE_LEVEL)

/proc/is_ai_allowed(z)
	return SSmapping.check_level_trait(z, AI_OK)

/proc/level_blocks_magic(z)
	return SSmapping.check_level_trait(z, IMPEDES_MAGIC)

/proc/level_boosts_signal(z)
	return SSmapping.check_level_trait(z, BOOSTS_SIGNAL)

// Used for the nuke disk, or for checking if players survived through xenos
/proc/is_secure_level(z)
	. = SSmapping.check_level_trait(z, STATION_LEVEL)
	if(!.)
		// This is to allow further admin levels later, other than centcomm
		return z == level_name_to_num(CENTCOMM)
