/datum/admins/key_down(_key, client/user)
	switch(_key)
		if("F5")
			user.admin_ghost()
			return
		if("F6")
			player_panel_new()
			return
		if("F7")
			user.cmd_admin_pm_panel()
			return
		if("F8")
			user.invisimin()
			return
	..()