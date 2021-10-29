GLOBAL_VAR_INIT(dchat_allowed, TRUE)

/datum/admins/proc/toggledchat()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead Chat"
	toggle_dchat()
	log_admin("[key_name(usr)] toggled dead chat.")
	message_admins("[key_name_admin(usr)] toggled dead chat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle DCHAT", "[GLOB.dchat_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/toggle_dchat(toggle = null)
	if(toggle != null) //if we're specifically en/disabling dead chat
		if(toggle != GLOB.dchat_allowed)
			GLOB.dchat_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.dchat_allowed = !GLOB.dchat_allowed
	to_chat(world, "<span class='oocplain'><B>The dead chat channel has been globally [GLOB.dchat_allowed ? "enabled" : "disabled"].</B></span>")
