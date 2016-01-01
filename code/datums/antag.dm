/datum/antag //This file doubles as the guide to creating a new antag
	var/list/barred_jobs = list() 				//list of assigned_roles that can't roundstart/latejoin as this antag
	var/list/protected_jobs = list()			//"                     " that can additionally be blocked from a config var if desired
	var/list/no_conversion_job = list() 		//"                     " that can't be CONVERTED to this antag
	var/list/barred_antag_list = list()			//list of special_roles that have bad synergy with this antag and are blocked (WizardBlob)
	var/list/created_from = list()				//sources of this antag, valid values are "roundstart", "latejoin", and "ghost".
	var/list/objectives = list()				//loadout of what this antag has to do to win
	var/datum/mind/antag	= null				//The associated mind of the antag
	var/status 									//checked occasionally to see if the antag is in a position that might make it less likely to be antagonistic. valid values are "alive", "objectives complete", "dead", "jailed" and "destroyed"
	var/ticks_since_last_status_update = 0		//To keep things from getting expensive, we run the status check about once a minute

/datum/antag/New()
	if(config.protect_roles_from_antagonist)
		barred_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		barred_jobs += "Assistant"

/datum/antag/process() //called by the game ticker
	if(!antag) //bad guy required!
		//Aquire_Candidate()
		return
	ticks_since_last_status_update = ++ticks_since_last_status_update
	if(ticks_since_last_status_update >= 60)
		Check_Status()
		ticks_since_last_status_update = 0

/datum/antag/proc/Check_Status()
	if(antag) //Checks are ordered by the intensity of running them
		if(!antag.current)
			status = "destroyed"
			return
		if(antag.current.stat == DEAD)
			status = "dead" //Not rocket science here
			return
		if(antag.current == /area/security/prison)
			status = "jailed"
			return
		if(objectives)
			var/all_objectives_complete = 1
			for(var/datum/objective/O in objectives)
				if(!O.check_completion())
					all_objectives_complete = 0
					break
			if(all_objectives_complete)
				status = "objectives complete"
				return
		status = "alive"
		return
	status = "no associated antag!"


/datum/antag/proc/Check_Compatibility(var/datum/mind/candidate, var/circumstance) //valid circumstances are "roundstart", "latejoin", and "ghost". Leaving circumstance blank is a way to override this proc (for example if loyalty implants matter).
	switch(circumstance)
		if("roundstart","latejoin")
			if(candidate.assigned_role in barred_jobs)
				return 0
	if(circumstance)
		antag = candidate
		return 1

/datum/antag/proc/Equip_Antag(var/circumstance) //conversion proc, should also override to give an antag special equipment
	return

/datum/antag/proc/Unequip_Antag() //deconversion proc, more important and likely to override in group antag datums
	return

