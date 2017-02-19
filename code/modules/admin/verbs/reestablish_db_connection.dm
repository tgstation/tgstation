/client/proc/reestablish_db_connection()
	set category = "Special Verbs"
	set name = "Reestablish DB Connection"
	if (!config.sql_enabled)
		to_chat(usr, "<span class='adminnotice'>The Database is not enabled!</span>")
		return

	if (dbcon && dbcon.IsConnected())
		if (!check_rights(R_DEBUG,0))
			alert("The database is already connected! (Only those with +debug can force a reconnection)", "The database is already connected!")
			return

		var/reconnect = alert("The database is already connected! If you *KNOW* that this is incorrect, you can force a reconnection", "The database is already connected!", "Force Reconnect", "Cancel")
		if (reconnect != "Force Reconnect")
			return

		dbcon.Disconnect()
		failed_db_connections = 0
		log_admin("[key_name(usr)] has forced the database to disconnect")
		message_admins("[key_name_admin(usr)] has <b>forced</b> the database to disconnect!")
		feedback_add_details("admin_verb","FRDB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	log_admin("[key_name(usr)] is attempting to re-established the DB Connection")
	message_admins("[key_name_admin(usr)] is attempting to re-established the DB Connection")
	feedback_add_details("admin_verb","RDB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	failed_db_connections = 0
	if (!establish_db_connection())
		message_admins("Database connection failed: " + dbcon.ErrorMsg())
	else
		message_admins("Database connection re-established")