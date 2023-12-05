/// String used in the message to notify admins if a permissions elevation attempt is detected
#define PERMISSIONS_ELEVATION_DETECTED_MESSAGE(user_string) "[##user_string] has tried to elevate permissions!"

/// Returns if the given client is an admin, REGARDLESS of if they're deadminned or not.
/proc/is_admin(client/client)
	return !isnull(GLOB.admin_datums[client.ckey]) || !isnull(GLOB.deadmins[client.ckey])

/// Sends a message in the event that someone attempts to elevate their permissions through invoking a certain proc.
/proc/alert_to_permissions_elevation_attempt(mob/user)
	message_admins(PERMISSIONS_ELEVATION_DETECTED_MESSAGE(key_name_admin(user)))
	log_admin(PERMISSIONS_ELEVATION_DETECTED_MESSAGE(key_name(user)))

#undef PERMISSIONS_ELEVATION_DETECTED_MESSAGE
