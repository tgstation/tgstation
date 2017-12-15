/datum/admins/key_down(_key, client/user)
	switch(_key)
		if("F5")
			user.cmd_admin_say(verbtextinput("Asay"))
			return
		if("F6")
			user.admin_ghost()
			return
		if("F7")
			user.stealth()
			return
		if("F8")
			user.togglebuildmodeself()
			return
	..()