/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"

	//if(Debug2)
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S,0,1,0)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1

	if(src.holder.rank == "Game Master" || src.holder.rank == "Game Admin" || src.holder.rank == "Badmin")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		for(var/mob/M in world)
			if(M.client)
				if(M.client.midis)
					M << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			for(var/mob/M in world)
				if(M.client)
					if(M.client.midis)
						M << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)
//	else
//		usr << "Cant play Sound."


	//else
	//	alert("Debugging is disabled")
	//	return

/client/proc/cuban_pete()
	set category = "Fun"
	set name = "Cuban Pete Time"

	message_admins("[key_name_admin(usr)] has declared Cuban Pete Time!", 1)

	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'cubanpetetime.ogg'

	for(var/mob/living/carbon/human/CP in world)
		if(CP.real_name=="Cuban Pete" && CP.key!="Rosham")
			CP << "Your body can't contain the rhumba beat"
			CP.gib(1)

/client/proc/bananaphone()
	set category = "Fun"
	set name = "Banana Phone"

	message_admins("[key_name_admin(usr)] has activated Banana Phone!", 1)

	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'bananaphone.ogg'





client/proc/space_asshole()
	set category = "Fun"
	set name = "Space Asshole"

	message_admins("[key_name_admin(usr)] has played the Space Asshole Hymn.", 1)

	for(var/mob/M in world)
		if(M.client)
			if(M.client.midis)
				M << 'space_asshole.ogg'



	/*if(Debug2)
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return

	var/sound/uploaded_sound = sound(S,0,1,0)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1

	if(src.holder.rank == "Game Master" || src.holder.rank == "Game Admin" || src.holder.rank == "Badmin")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		world << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			world << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)*/