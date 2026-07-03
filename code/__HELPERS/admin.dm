/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client/client)
	return !isnull(GLOB.admin_datums[client.ckey]) || !isnull(GLOB.deadmins[client.ckey])

/// BANDASTATION ADIITION START - Loadout
/// Returns admin rights player has, REGARDLESS of if they're deadminned or not.
/proc/get_player_admin_flags(client/client)
	if(CONFIG_GET(flag/enable_localhost_rank) && client.is_localhost())
		return R_EVERYTHING

	var/datum/admins/holder = GLOB.admin_datums[client.ckey] || GLOB.deadmins[client.ckey]
	return holder?.rank_flags()
/// BANDASTATION ADIITION END - Loadout

/// Sends a message in the event that someone attempts to elevate their permissions through invoking a certain proc.
/proc/alert_to_permissions_elevation_attempt(mob/user)
	var/message = " has tried to elevate permissions!"
	message_admins(key_name_admin(user) + message)
	log_admin(key_name(user) + message)
