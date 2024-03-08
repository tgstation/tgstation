/datum/verbs/menu/Admin/Generate_list(client/C)
	if (C.holder)
		. = ..()

/datum/verbs/menu/Admin/verb/playerpanel()
	set name = "Player Panel"
	set desc = "Player Panel"
	set category = "Admin.Game"
	if(usr.client.holder)
		usr.client.holder.player_panel_new()
		BLACKBOX_LOG_ADMIN_VERB("Player Panel New")
