/datum/admins/key_down(_key, client/user)
	switch(_key)
		if("F4")
			user.cmd_mentor_say()
			return
	..()
