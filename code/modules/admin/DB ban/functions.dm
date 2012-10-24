
datum/admins/proc/DB_ban_record(var/bantype, var/mob/banned_mob, var/duration = -1, var/reason, var/job = "", var/rounds = 0)
	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!dbcon.IsConnected())
		return

	var/serverip = "[world.internet_address]:[world.port]"
	var/bantype_pass = 0
	var/bantype_str
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1
	if( !bantype_pass ) return
	if( !istext(reason) ) return
	if( !isnum(duration) ) return

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address

	var/a_ckey
	var/a_computerid
	var/a_ip

	if(src.owner && istype(src.owner, /client))
		a_ckey = src.owner:ckey
		a_computerid = src.owner:computer_id
		a_ip = src.owner:address

	var/who
	for(var/client/C in clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"

	reason = sql_sanitize_text(reason)

	var/sql = "INSERT INTO erro_ban VALUES (null, Now(), '[serverip]', '[bantype_str]', '[reason]', '[job]', [(duration)?"[duration]":"0"], [(rounds)?"[rounds]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[ckey]', '[computerid]', '[ip]', '[a_ckey]', '[a_computerid]', '[a_ip]', '[who]', '[adminwho]', '', null, null, null, null, null)"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()

	dbcon.Disconnect()



datum/admins/proc/DB_ban_unban(var/ckey, var/bantype, var/job = "")
	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/bantype_str
	if(bantype)
		var/bantype_pass = 0
		switch(bantype)
			if(BANTYPE_PERMA)
				bantype_str = "PERMABAN"
				bantype_pass = 1
			if(BANTYPE_TEMP)
				bantype_str = "TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_JOB_PERMA)
				bantype_str = "JOB_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_JOB_TEMP)
				bantype_str = "JOB_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "bantype = '[bantype_str]'"

	var/sql = "SELECT id FROM erro_ban WHERE ckey = '[ckey]' AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	if(job)
		sql += " AND job = '[job]'"

	var/DBConnection/dbcon = new()

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!dbcon.IsConnected())
		return

	var/ban_id
	var/ban_number = 0 //failsafe

	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++;

	if(ban_number == 0)
		usr << "\red Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin."
		return

	if(ban_number > 1)
		usr << "\red Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin."
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		usr << "\red Database update failed due to a ban ID mismatch. Contact the database admin."
		return

	DB_ban_unban_by_id(ban_id)


datum/admins/proc/DB_ban_unban_by_id(var/id)
	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/sql = "SELECT id FROM erro_ban WHERE id = [id]"

	var/DBConnection/dbcon = new()

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(!dbcon.IsConnected())
		return

	var/ban_number = 0 //failsafe

	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		ban_number++;

	if(ban_number == 0)
		usr << "\red Database update failed due to a ban id not being present in the database."
		return

	if(ban_number > 1)
		usr << "\red Database update failed due to multiple bans having the same ID. Contact the database admin."
		return

	if(!src.owner || !istype(src.owner, /client))
		return

	var/unban_ckey = src.owner:ckey
	var/unban_computerid = src.owner:computer_id
	var/unban_ip = src.owner:address

	var/sql_update = "UPDATE erro_ban SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[unban_ckey]', unbanned_computerid = '[unban_computerid]', unbanned_ip = '[unban_ip]' WHERE id = [id]"


	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	query_update.Execute()