/datum/mentors/key_down(_key, client/user)
	switch(_key)
		if("F4")
			user.get_mentor_say()
			return
	..()
