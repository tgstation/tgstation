//ban people from using custom names and appearances. that'll show 'em.

var/appearanceban_runonce	//Updates legacy bans with new info
var/appearance_keylist[0]	//to store the keys

/proc/appearance_fullban(mob/M, reason)
	if (!M || !M.key) return
	appearance_keylist.Add(text("[M.ckey] ## [reason]"))
	appearance_savebanfile()

/proc/appearance_client_fullban(ckey)
	if (!ckey) return
	appearance_keylist.Add(text("[ckey]"))
	appearance_savebanfile()

//returns a reason if M is banned, returns 0 otherwise
/proc/appearance_isbanned(mob/M)
	if(M)
		for(var/s in appearance_keylist)
			if(findtext(s, "[M.ckey]") == 1)
				var/startpos = findtext(s, "## ") + 3
				if(startpos && startpos < length(s))
					var/text = copytext(s, startpos, 0)
					if(text)
						return text
				return "Reason Unspecified"
	return 0

/*
DEBUG
/mob/verb/list_all_appearances()
	set name = "list all appearances"

	for(var/s in appearance_keylist)
		world << s

/mob/verb/reload_appearances()
	set name = "reload appearances"

	appearance_loadbanfile()
*/

/proc/appearance_loadbanfile()
	if(config.ban_legacy_system)
		var/savefile/S=new("data/appearance_full.ban")
		S["keys[0]"] >> appearance_keylist
		log_admin("Loading appearance_rank")
		S["runonce"] >> appearanceban_runonce

		if (!length(appearance_keylist))
			appearance_keylist=list()
			log_admin("appearance_keylist was empty")
	else
		if(!establish_db_connection())
			world.log << "Database connection failed. Reverting to the legacy ban system."
			diary << "Database connection failed. Reverting to the legacy ban system."
			config.ban_legacy_system = 1
			appearance_loadbanfile()
			return

		//appearance bans
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM erro_ban WHERE bantype = 'APPEARANCE_BAN' AND NOT unbanned = 1")
		query.Execute()

		while(query.NextRow())
			var/ckey = query.item[1]

			appearance_keylist.Add("[ckey]")

/proc/appearance_savebanfile()
	var/savefile/S=new("data/appearance_full.ban")
	S["keys[0]"] << appearance_keylist

/proc/appearance_unban(mob/M)
	appearance_remove("[M.ckey]")
	appearance_savebanfile()


/proc/appearance_updatelegacybans()
	if(!appearanceban_runonce)
		log_admin("Updating appearancefile!")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in appearance_keylist)
			if(!T)	continue
		appearanceban_runonce++	//don't run this update again


/proc/appearance_remove(X)
	for (var/i = 1; i <= length(appearance_keylist); i++)
		if( findtext(appearance_keylist[i], "[X]") )
			appearance_keylist.Remove(appearance_keylist[i])
			appearance_savebanfile()
			return 1
	return 0

/*
proc/DB_ban_isappearancebanned(var/playerckey)
	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sqlplayerckey = sql_sanitize_text(ckey(playerckey))

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_ban WHERE CKEY = '[sqlplayerckey]' AND ((bantype = 'APPEARANCE_BAN') OR (bantype = 'APPEARANCE_TEMPBAN' AND expiration_time > Now())) AND unbanned != 1")
	query.Execute()
	while(query.NextRow())
		return 1
	return 0
*/