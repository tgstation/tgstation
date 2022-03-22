/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client/client)
	return !isnull(GLOB.admin_datums[client.ckey]) || !isnull(GLOB.deadmins[client.ckey])
