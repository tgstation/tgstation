//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank, reason)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_fullban() called tick#: [world.time]")
	if (!M || !M.key) return
	jobban_keylist.Add(text("[M.ckey] - [rank] ## [reason]"))
	jobban_savebanfile()

/proc/jobban_client_fullban(ckey, rank)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_client_fullban() called tick#: [world.time]")
	if (!ckey || !rank) return
	jobban_keylist.Add(text("[ckey] - [rank]"))
	jobban_savebanfile()

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_isbanned() called tick#: [world.time]")
	if(M && rank)
		/*
		if(_jobban_isbanned(M, rank)) return "Reason Unspecified"	//for old jobban
		if (guest_jobbans(rank))
			if(config.guest_jobban && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(config.usewhitelist && !check_whitelist(M))
				return "Whitelisted Job"
		*/
		for (var/s in jobban_keylist)
			if( findtext(s,"[M.ckey] - [rank]") == 1 )
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/verb/list_all_jobbans()  called tick#: [world.time]")
	set name = "list all jobbans"

	for(var/s in jobban_keylist)
		world << s

/mob/verb/reload_jobbans()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/verb/reload_jobbans()  called tick#: [world.time]")
	set name = "reload jobbans"

	jobban_loadbanfile()
*/

/proc/jobban_loadbanfile()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_loadbanfile() called tick#: [world.time]")
	if(config.ban_legacy_system)
		var/savefile/S=new("data/job_full.ban")
		S["keys[0]"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if (!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")
	else
		if(!establish_db_connection())
			world.log << "Database connection failed. Reverting to the legacy ban system."
			diary << "Database connection failed. Reverting to the legacy ban system."
			config.ban_legacy_system = 1
			jobban_loadbanfile()
			return

		//Job permabans
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_PERMABAN' AND isnull(unbanned)")
		query.Execute()

		while(query.NextRow())
			var/ckey = query.item[1]
			var/job = query.item[2]

			jobban_keylist.Add("[ckey] - [job]")

		//Job tempbans
		var/DBQuery/query1 = dbcon.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")
		query1.Execute()

		while(query1.NextRow())
			var/ckey = query1.item[1]
			var/job = query1.item[2]

			jobban_keylist.Add("[ckey] - [job]")

/proc/jobban_savebanfile()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_savebanfile() called tick#: [world.time]")
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_unban() called tick#: [world.time]")
	jobban_remove("[M.ckey] - [rank]")
	jobban_savebanfile()


/proc/ban_unban_log_save(var/formatted_log)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/ban_unban_log_save() called tick#: [world.time]")
	text2file(formatted_log,"data/ban_unban_log.txt")


/proc/jobban_updatelegacybans()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_updatelegacybans() called tick#: [world.time]")
	if(!jobban_runonce)
		log_admin("Updating jobbanfile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!T)	continue
		jobban_runonce++	//don't run this update again


/proc/jobban_remove(X)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/jobban_remove() called tick#: [world.time]")
	for (var/i = 1; i <= length(jobban_keylist); i++)
		if( findtext(jobban_keylist[i], "[X]") )
			jobban_keylist.Remove(jobban_keylist[i])
			jobban_savebanfile()
			return 1
	return 0
