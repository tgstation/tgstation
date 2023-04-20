ADMIN_VERB(connect_db, "Re-Establish DB Connection", "Attempts to reconnect the database, optionally forcing a disconnect if it is already connected.", NONE, VERB_CATEGORY_ADMIN)
	if(!CONFIG_GET(flag/sql_enabled))
		tgui_alert(user, "The database is not enabled!", "Re-Establish DB Connection")
		return

	if(SSdbcore.IsConnected())
		if(!check_rights_for(user, R_DEBUG))
			tgui_alert(user, "The database is already connected, and you do not have permission to force a reconnection!", "Re-Establish DB Connection")
			return

		var/force_reconnect = tgui_alert(
			user,
			"The data base is already connected; If you are certain that this is incorrect, you can force a reconnection",
			"Re-Establish DB Connection",
			list("Force", "Cancel"),
			) == "Force"
		if(!force_reconnect)
			return

		var/message = "[key_name(user)] has forced the database to disconnect."
		SSdbcore.Disconnect()
		log_admin(message)
		message_admins(message)

	var/message = "[key_name(user)] is attempted to re-establish the DB connection."
	log_admin(message)
	message_admins(message)

	SSdbcore.failed_connections = 0
	if(!SSdbcore.Connect())
		message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
	else
		message_admins("Database connection re-established")
