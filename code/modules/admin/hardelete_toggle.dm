/client/proc/hard_deletion_toggle()
	set category = "Debug"
	set name = "Enable/Disable Hard Deletes"

	var/static/list/warned_users

	LAZYINITLIST(warned_users)
	var/current_val = SSgarbage.enable_hard_deletes
	if (current_val && !warned_users[usr.ckey])
		to_chat(usr, "WARNING: Disabling garbage hard deletion will likely result in permanent memory leaks until the next round. Run this verb again to disable it.")
		warned_users[usr.ckey] = TRUE
		return

	SSgarbage.enable_hard_deletes = !current_val

	log_admin("[key_name(usr)] toggled garbage hard deletion [SSgarbage.enable_hard_deletes ? "ON" : "OFF"].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "hard_deletion_toggle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
