/mob/verb/togglemidis()
	set category = "Special Verbs"
	set name = "Toggle Midis"

	if(istype(usr,/mob))
		var/mob/M = usr
		M.midis = !M.midis

		if(M.client)
			M.client.midis = !M.client.midis
			M << "You will now [M.client.midis? "start":"stop"] receiving any sounds uploaded by admins."
		return