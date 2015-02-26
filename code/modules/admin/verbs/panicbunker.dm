/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"
	if (!config.sql_enabled)
		usr << "<span class='adminnotice'>The Database is not enabled!</span>"
		return

	if (!dbcon || !dbcon.IsConnected())
		usr << "<span class='adminnotice'>The Database is not connected!</span>"
		return

	config.panic_bunker = (!config.panic_bunker)
	log_admin("[key_name(usr)] has toggled the Panic Bunker, it is now [(config.panic_bunker?"on":"off")]")
	message_admins("[key_name_admin(usr)] has toggled the Panic Bunker, it is now [(config.panic_bunker?"on":"off")]")
	feedback_add_details("admin_verb","PANIC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

