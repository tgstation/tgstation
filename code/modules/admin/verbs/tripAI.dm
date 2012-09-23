/client/proc/triple_ai()
	set category = "Fun"
	set name = "Create AI Triumvirate"

	if(ticker.current_state > GAME_STATE_PREGAME)
		usr << "This option is currently only usable during pregame. This may change at a later date."
		return
	if(job_master && ticker)
		var/datum/job/job = job_master.GetJob("AI")
		if(!job)
			usr << "Unable to locate the AI job"
			return
		if(ticker.triai)
			ticker.triai = 0
			usr << "Only one AI will be spawned at round start."
			message_admins("\blue [key_name_admin(usr)] has toggled off triple AIs at round start.", 1)
		else
			ticker.triai = 1
			usr << "There will be an AI Triumvirate at round start."
			message_admins("\blue [key_name_admin(usr)] has toggled on triple AIs at round start.", 1)
	feedback_add_details("admin_verb","CAIT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
