
datum/admins/proc/DB_ban_record(var/bantype, var/mob/banned_mob, var/duration = -1, var/reason, var/job = "", var/rounds = 0, var/banckey = null)
	establish_db_connection()
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
	else if(banckey)
		ckey = ckey(banckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_player WHERE ckey = '[ckey]'")
	query.Execute()
	var/validckey = 0
	if(query.NextRow())
		validckey = 1
	if(!validckey)
		message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</font>",1)
		return

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
	usr << "\blue Ban saved to database."
	message_admins("[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)



datum/admins/proc/DB_ban_unban(var/ckey, var/bantype, var/job = "")

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

	establish_db_connection()
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

datum/admins/proc/DB_ban_edit(var/banid = null, var/param = null)

	if(!isnum(banid) || !istext(param))
		usr << "Cancelled"
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey, duration, reason FROM erro_ban WHERE id = [banid]")
	query.Execute()

	var/eckey = usr.ckey	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason

	if(query.NextRow())
		pckey = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
	else
		usr << "Invalid ban id. Contact the database admin"
		return

	reason = sql_sanitize_text(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text
				value = sql_sanitize_text(value)
				if(!value)
					usr << "Cancelled"
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET reason = '[value]', edits = CONCAT(edits,'- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><BR>') WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]",1)
		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					usr << "Cancelled"
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET duration = [value], edits = CONCAT(edits,'- [eckey] changed ban duration from [duration] to [value]<br>'), expiration_time = DATE_ADD(bantime, INTERVAL [value] MINUTE) WHERE id = [banid]")
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]",1)
			update_query.Execute()
		if("unban")
			if(alert("Unban [pckey]?", "Unban?", "Yes", "No") == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				usr << "Cancelled"
				return
		else
			usr << "Cancelled"
			return

datum/admins/proc/DB_ban_unban_by_id(var/id)

	var/sql = "SELECT ckey FROM erro_ban WHERE id = [id]"

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/ban_number = 0 //failsafe

	var/pckey
	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		pckey = query.item[1]
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
	message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.",1)

	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	query_update.Execute()


/client/proc/DB_ban_panel()
	set category = "Admin"
	set name = "Banning Panel"
	set desc = "Edit admin permissions"

	if(!holder)
		return

	holder.DB_ban_panel()


/datum/admins/proc/DB_ban_panel(var/playerckey = null, var/adminckey = null)
	if(!usr.client)
		return

	//if(check_rights(R_BAN))
	//	usr << "\red You do not have permission to do this!"
	//	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	output += "<td width='35%' align='center'>"
	output += "<h1>Banning panel</h1>"
	output += "</td>"

	output += "<td width='65%' align='center' bgcolor='#f9f9f9'>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<table width='100%'><tr>"
	output += "<td><b>Ban type:</b><select name='dbbanaddtype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "</select></td>"
	output += "<td><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	output += "</select></td></tr></table>"
	output += "<b>Reason:<br></b><textarea name='dbbanreason' cols='50'></textarea><br>"
	output += "<input type='submit' value='Add ban'>"
	output += "</form>"

	output += "</td>"
	output += "</tr>"
	output += "</table>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Search:</b> "
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<b>Ckey:</b> <input type='text' name='dbsearchckey' value='[playerckey]'>"
	output += "<b>Admin ckey:</b> <input type='text' name='dbsearchadmin' value='[adminckey]'>"
	output += "<input type='submit' value='search'>"
	output += "</form>"
	output += "Please note that all jobban bans or unbans are in-effect the following round."

	if(adminckey || playerckey)

		var/blcolor = "#ffeeee" //banned light
		var/bdcolor = "#ffdddd" //banned dark
		var/ulcolor = "#eeffee" //unbanned light
		var/udcolor = "#ddffdd" //unbanned dark

		output += "<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>"
		output += "<tr>"
		output += "<th width='25%'><b>TYPE</b></th>"
		output += "<th width='20%'><b>CKEY</b></th>"
		output += "<th width='20%'><b>TIME APPLIED</b></th>"
		output += "<th width='20%'><b>ADMIN</b></th>"
		output += "<th width='15%'><b>OPTIONS</b></th>"
		output += "</tr>"

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)
		var/adminsearch = ""
		var/playersearch = ""
		if(adminckey)
			adminsearch = "AND a_ckey = '[adminckey]' "
		if(playerckey)
			playersearch = "AND ckey = '[playerckey]' "

		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, bantime, bantype, reason, job, duration, expiration_time, ckey, a_ckey, unbanned, unbanned_ckey, unbanned_datetime, edits FROM erro_ban WHERE 1 [playersearch] [adminsearch] ORDER BY bantime DESC")
		select_query.Execute()

		while(select_query.NextRow())
			var/banid = select_query.item[1]
			var/bantime = select_query.item[2]
			var/bantype  = select_query.item[3]
			var/reason = select_query.item[4]
			var/job = select_query.item[5]
			var/duration = select_query.item[6]
			var/expiration = select_query.item[7]
			var/ckey = select_query.item[8]
			var/ackey = select_query.item[9]
			var/unbanned = select_query.item[10]
			var/unbanckey = select_query.item[11]
			var/unbantime = select_query.item[12]
			var/edits = select_query.item[13]

			var/lcolor = blcolor
			var/dcolor = bdcolor
			if(unbanned)
				lcolor = ulcolor
				dcolor = udcolor

			var/typedesc =""
			switch(bantype)
				if("PERMABAN")
					typedesc = "<font color='red'><b>PERMABAN</b></font>"
				if("TEMPBAN")
					typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
				if("JOB_PERMABAN")
					typedesc = "<b>JOBBAN</b><br><font size='2'>([job])"

			output += "<tr bgcolor='[dcolor]'>"
			output += "<td align='center'>[typedesc]</td>"
			output += "<td align='center'><b>[ckey]</b></td>"
			output += "<td align='center'>[bantime]</td>"
			output += "<td align='center'><b>[ackey]</b></td>"
			output += "<td align='center'>[(unbanned) ? "" : "<b><a href=\"byond://?src=\ref[src];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
			output += "</tr>"
			output += "<tr bgcolor='[lcolor]'>"
			output += "<td align='center' colspan='5'><b>Reason: [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
			output += "</tr>"
			if(edits)
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='5'><b>EDITS</b></td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
				output += "</tr>"
			if(unbanned)
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanckey] on [unbantime]</b></td>"
				output += "</tr>"
			output += "<tr>"
			output += "<td colspan='5' bgcolor='white'>&nbsp</td>"
			output += "</tr>"

		output += "</table></div>"

	usr << browse(output,"window=lookupbans;size=900x500")