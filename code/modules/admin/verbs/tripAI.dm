/client/proc/triple_ai()
	set category = "Fun"
	set name = "Create AI Triumvirate"

	if(ticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame. This may change at a later date.")
		return

	if(job_master && ticker)
		var/datum/job/job = job_master.GetJob("AI")
		if(!job)
			to_chat(usr, "Unable to locate the AI job")
			return
		if(ticker.triai)
			ticker.triai = 0
			to_chat(usr, "Only one AI will be spawned at round start.")
			message_admins("<span class='notice'>[key_name_admin(usr)] has toggled off triple AIs at round start.</span>", 1)
		else
			ticker.triai = 1
			to_chat(usr, "There will be an AI Triumvirate at round start.")
			message_admins("<span class='notice'>[key_name_admin(usr)] has toggled on triple AIs at round start.</span>", 1)
	return
