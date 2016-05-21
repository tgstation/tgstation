//Code to update legacy appearance bans to jobbans

/proc/appearance_loadbanfile()
	if(config.ban_legacy_system)
		return
	else
		if(!establish_db_connection())
			world.log << "Database connection failed."
			diary << "Database connection failed."
			config.ban_legacy_system = 1
			return

		//appearance bans
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM [format_table_name("ban")] WHERE bantype = 'APPEARANCE_PERMABAN' AND NOT unbanned = 1")
		query.Execute()

		while(query.NextRow())
			var/ckeyb = query.item[1]

			var/datum/admins/db = new()
			db.DB_ban_unban(ckeyb, BANTYPE_APPEARANCE)

			var/mob/playermob
			var/exist = 0
			for(var/mob/M in player_list)
				if(M.ckey == ckeyb)
					playermob = M
					exist = 1
					break

			if(!exist)
				playermob.ckey = ckeyb

			db.DB_ban_record(BANTYPE_JOB_PERMA, playermob, -1, "Legacy", "Appearance")
