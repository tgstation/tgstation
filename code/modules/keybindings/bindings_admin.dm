/datum/admins/key_down(_key, client/user)
	switch(_key)
		if("F3")
			user.get_admin_say()
			return
		if("F5")
			user.cmd_admin_say(verbtextinput("Asay"))
			return
		if("F6")
			player_panel_new()
			return
		if("F7")
			user.stealth()
			return
		if("F8")
			user.togglebuildmodeself()
			return
	..()
