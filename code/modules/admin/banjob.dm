var
	jobban_runonce	// Updates legacy bans with new info
	jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank)
	if (!M || !M.key || !M.client) return
	jobban_keylist.Add(text("[M.ckey] - [rank]"))
	jobban_savebanfile()

/proc/jobban_isbanned(mob/M, rank)
	if(M)
		if (rank == "Captain" || rank == "AI" || rank == "Head of Personnel" || rank == "Head of Security" || rank == "Chief Engineer" || rank == "Research Director" || rank == "Warden" || rank == "Detective" || rank == "Chief Medical Officer")
			if(IsGuestKey(M.key)/* && config.guest_jobban*/)
				return 1
		if (jobban_keylist.Find(text("[M.ckey] - [rank]")))
			return 1
		else
			return 0

/proc/jobban_loadbanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] >> jobban_keylist
	log_admin("Loading jobban_rank")
	S["runonce"] >> jobban_runonce
	if (!length(jobban_keylist))
		jobban_keylist=list()
		log_admin("jobban_keylist was empty")

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_keylist.Remove(text("[M.ckey] - [rank]"))
	jobban_savebanfile()

/proc/jobban_updatelegacybans()
	if(!jobban_runonce)
		log_admin("Updating jobbanfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!T)	continue
		jobban_runonce++	//don't run this update again

/proc/jobban_remove(X)
	if(jobban_keylist.Find(X))
		jobban_keylist.Remove(X)
		jobban_savebanfile()
		return 1
	return 0