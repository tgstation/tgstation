/proc/kick_client(client/to_kick)
	// Pretty much everything in this proc is copied straight from `code/modules/admin/topic.dm`,
	// proc `/datum/admins/Topic()`, href `"boot2"`. If it breaks here, it was probably broken there
	// too.
	if(!check_rights(R_ADMIN))
		return
	if(!to_kick)
		to_chat(usr, span_danger("Error: The client you specified has disappeared!"), confidential = TRUE)
		return
	if(!check_if_greater_rights_than(to_kick))
		to_chat(usr, span_danger("Error: They have more rights than you do."), confidential = TRUE)
		return
	to_chat(to_kick, span_danger("You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"]."), confidential = TRUE)
	log_admin("[key_name(usr)] kicked [key_name(to_kick)].")
	message_admins(span_adminnotice("[key_name_admin(usr)] kicked [key_name_admin(to_kick)]."))
	qdel(to_kick)
