/client/proc/fax()
	set name = "Fax Manager"
	set desc = "Open the manager panel to view all requests during this round"
	set category = "Admin.Game"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Fax Manager") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.fax_manager.ui_interact(usr)
