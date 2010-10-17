/mob/verb/togglemidis()
	set category = "Special Verbs"
	set name = "Toggle Midis"

	if(usr.midis)
		usr.midis=0
		usr << "You will now stop receiving any sounds uploaded by admins."
	else
		usr.midis=1
		usr << "You will now start receiving any sounds uploaded by admins."
	return