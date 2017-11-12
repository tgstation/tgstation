/datum/verbs/menu/Admin/Generate_list(client/C)
	if (C.holder)
		. = ..()

/datum/verbs/menu/Admin/verb/playerpanel()
	set name = "Player Panel"
	set desc = "Player Panel"
	set category = "Admin"
	if(check_rights_for(usr.client, R_ADMIN))
		usr.client.holder.player_panel_new()
		SSblackbox.add_details("admin_verb","Player Panel New") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
