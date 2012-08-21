//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank, reason)
	if (!M || !M.key) return
	jobban_keylist.Add(text("[M.ckey] - [rank] ## [reason]"))
	jobban_savebanfile()

/proc/jobban_client_fullban(ckey, rank)
	if (!ckey || !rank) return
	jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(M && rank)
		if(_jobban_isbanned(M, rank)) return "Reason Unspecified"	//for old jobban
		if (guest_jobbans(rank))
			if(config.guest_jobban && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(config.usewhitelist && !check_whitelist(M))
				return "Whitelisted Job"

		for (var/s in jobban_keylist)
			if( findtext(s,"[M.ckey] - [rank]") )
				var/startpos = findtext(s, "## ")+3
				if(startpos && startpos<length(s))
					var/text = copytext(s, startpos, 0)
					if(text)
						return text
				return "Reason Unspecified"
	return 0

/*
DEBUG
/mob/verb/list_all_jobbans()
	set name = "list all jobbans"

	for(var/s in jobban_keylist)
		world << s

/mob/verb/reload_jobbans()
	set name = "reload jobbans"

	jobban_loadbanfile()
*/

/proc/jobban_loadbanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] >> jobban_keylist
	log_admin("Loading jobban_rank")
	S["runonce"] >> jobban_runonce

	/*
	for(var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i],"##") )
			var/index = findtext(jobban_keylist[i],"##")
			var/s = jobban_keylist[i]
			s = copytext( s , 1 , index ) //Removes the reason for the ban from this list
			jobban_keylist[i] = s
			world << "DEBUG: index: [index] - s: [s] - jobban_keylist\[[i]\] = [jobban_keylist[i]]"*/

	if (!length(jobban_keylist))
		jobban_keylist=list()
		log_admin("jobban_keylist was empty")


/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [rank]")
	jobban_savebanfile()


/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_updatelegacybans()
	if(!jobban_runonce)
		log_admin("Updating jobbanfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!T)	continue
		jobban_runonce++	//don't run this update again


/proc/jobban_remove(X)
	for (var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i], "[X]") )
			jobban_keylist.Remove(jobban_keylist[i])
			jobban_savebanfile()
			return 1
	return 0
