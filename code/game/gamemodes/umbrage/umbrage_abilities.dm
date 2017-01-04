//Mindlink: Basic hive mind. Umbrages can communicate silently to their allies on the same z.
/datum/action/innate/umbrage_comms
	name = "Mindlink"
	button_icon_state = "alien_whisper"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/umbrage_comms/IsAvailable()
	//Umbrage check goes here
	return ..()

/datum/action/innate/umbrage_comms/Activate()
	var/message = stripped_input(usr, "Enter a message to tell your nearby allies.", "Mindlink", "")
	if(!message || !IsAvailable())
		return
	var/processed_message
	if(is_umbrage(usr.mind))
		if(!is_umbrage_progenitor(usr.mind))
			processed_message = "<span class='shadowling'><b>\[Mindlink\] Umbrage [usr.real_name]:</b> \"[message]\"</span>"
		else
			processed_message = "<font size=3><span class='shadowling'><b>\[Mindlink\] Progenitor [usr.real_name]:</b> \"[message]\"</span></font>" //Progenitors get big spooky text
	else if(is_veil(usr.mind))
		processed_message = "<span class='shadowling'><b>\[Mindlink\] [usr.real_name]:</b> \"[message]\""
	else
		return 0 //How are you doing this in the first place?
	for(var/V in ticker.mode.umbrages_and_veils)
		var/datum/mind/M = V
		if(M.current.z != usr.z)
			if(prob(10))
				M.current << "<span class='warning'>Your mindlink trembles with words, but you're too far away to make it out...</span>"
			continue
		else
			M.current << processed_message
	for(var/mob/M in dead_mob_list)
		M << processed_message
	return 1
