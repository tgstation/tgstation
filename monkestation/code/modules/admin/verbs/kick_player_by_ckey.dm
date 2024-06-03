/datum/admins/proc/kick_player_by_ckey()
	set name = "Kick Player (by ckey)"
	set category = "Admin"

	// Pretty much everything here except the client selection is copied straight from
	// `code/modules/admin/topic.dm`, proc `/datum/admins/Topic()`, href `"boot2"`. If it breaks
	// here, it was probably broken there too.
	if(!check_rights(R_ADMIN))
		return

	var/client/to_kick = input(usr, "Select a ckey to kick.", "Select a ckey") as null|anything in sort_list(GLOB.clients)
	if(!to_kick)
		return

	var/confirmation = alert(usr, "Kick [key_name(to_kick)]?", "Confirm", "Yes", "No")
	if(confirmation != "Yes")
		return

	kick_client(to_kick)
