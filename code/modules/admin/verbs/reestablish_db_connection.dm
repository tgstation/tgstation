/client/proc/reestablish_db_connection()
	set category = "Special Verbs"
	set name = "Reestablish DB Connection"

	if (dbcon && dbcon.IsConnected())
		if (!check_rights(R_DEBUG,0))
			alert("The database is already connected! (Only those with +debug can force a reconnection)", "The database is already connected!")
			return

		var/reconnect = alert("The database is already connected! If you *KNOW* that this is incorrect, you can force a reconnection", "The database is already connected!", "Force Reconnect", "Cancel")
		if (reconnect != "Force Reconnect")
			return

		dbcon.Disconnect()
		failed_db_connections = 0
		log_admin("[key_name(usr)] Has forced the database to reconnect")
		message_admins("[key_name_admin(usr)] Has <b>forced</b> the database to reconnect")
		feedback_add_details("admin_verb","FRDB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


	failed_db_connections = 0
	spawn(0)
		establish_db_connection()

	log_admin("[key_name(usr)] Has re-established the DB Connection")
	message_admins("[key_name_admin(usr)] Has re-established the DB Connection")
	feedback_add_details("admin_verb","RDB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!