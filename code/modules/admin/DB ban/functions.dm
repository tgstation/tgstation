#define MAX_ADMIN_BANS_PER_ADMIN 1

//Either pass the mob you wish to ban in the 'banned_mob' attribute, or the banckey, banip and bancid variables. If both are passed, the mob takes priority! If a mob is not passed, banckey is the minimum that needs to be passed! banip and bancid are optional.
/datum/admins/proc/DB_ban_record(mob/banned_mob, duration = null, reason, job = null, banckey = null, banip = null, bancid = null, applies_to_admins = null)

	if(!check_rights(R_BAN))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/serverip = "[world.internet_address]:[world.port]"
	var/kickbannedckey		//Defines whether this proc should kick the banned person, if they are connected (if banned_mob is defined).
							//some ban types kick players after this proc passes (tempban, permaban), but some are specific to db_ban, so
							//they should kick within this proc.

	if(!duration || duration < 0)
		duration = null

	if(applies_to_admins)
		kickbannedckey = 1

	if( !istext(reason) ) return

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
		else
			computerid = banned_mob.computer_id
			ip = banned_mob.lastKnownIP
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	query.Execute()
	var/validckey = 0
	if(query.NextRow())
		validckey = 1
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</font>",1)
			return

	var/a_ckey
	var/a_computerid
	var/a_ip

	if(src.owner && istype(src.owner, /client))
		a_ckey = src.owner:ckey
		a_computerid = src.owner:computer_id
		a_ip = src.owner:address

	if(!job && (a_ckey == ckey))
		usr << "<span class='danger'>You cannot server ban yourself.</span>"
		return

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

	reason = sanitizeSQL(reason)

	if(applies_to_admins) //damage control against rogue admins
		var/DBQuery/adm_query = dbcon.NewQuery("SELECT count(id) AS num FROM [format_table_name("ban")] WHERE (a_ckey = '[a_ckey]') AND applies_to_admins = 1 AND isnull(job) AND (isnull(expiration_time) OR expiration_time > Now()) AND isnull(unbanned)")
		adm_query.Execute()
		if(adm_query.NextRow())
			var/adm_bans = text2num(adm_query.item[1])
			if(adm_bans >= MAX_ADMIN_BANS_PER_ADMIN)
				usr << "<span class='danger'>You already logged [MAX_ADMIN_BANS_PER_ADMIN] admin ban(s) or more. Do not abuse this function!</span>"
				return

	var/sql = "INSERT INTO [format_table_name("ban")] (`id`,`bantime`,`serverip`,`reason`,`job`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`applies_to_admins`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`) VALUES (null, Now(), '[serverip]', '[reason]', '[job]', [duration ? "Now() + INTERVAL [duration] MINUTE" : "null"], '[ckey]', '[computerid]', '[ip]', '[a_ckey]', '[a_computerid]', '[a_ip]', [applies_to_admins ? "'1'" : null], '[who]', '[adminwho]', '', null, null, null, null, null)"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	usr << "<span class='adminnotice'>Ban saved to database.</span>"
	message_admins("[key_name_admin(usr)] has added a [applies_to_admins ? "ADMIN " : ""][job ? "Job " : ""][duration ? "Temp" : "Perma"]ban for [ckey] [(job)?"([job])":""] [duration ?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)

	if(applies_to_admins)
		send2irc("BAN ALERT","[a_ckey] applied an adminban on [ckey]")

	if(kickbannedckey)
		if(banned_mob && banned_mob.client && banned_mob.client.ckey == banckey)
			del(banned_mob.client)


/datum/admins/proc/DB_ban_unban(ckey, bantype, job = null, applies_to_admins = null)

	if(!check_rights(R_BAN))
		return

	var/bantype_sql
	if(bantype == BANTYPE_ANY_FULLBAN)
		bantype_sql = "(isnull(expiration_time) OR expiration_time > Now())"
	else if(bantype == BANTYPE_ANY_JOB)
		bantype_sql = "NOT isnull(job) AND (isnull(expiration_time) OR expiration_time > Now())"

	var/sql = "SELECT id FROM [format_table_name("ban")] WHERE ckey = '[ckey]' AND [bantype_sql] AND isnull(unbanned)"

	if(job == 0)
		sql += " AND isnull(job)"
	else if(job)
		sql += " AND job = '[job]'"

	if(applies_to_admins == 0)
		sql += " AND isnull(applies_to_admins)"
	else if(applies_to_admins)
		sql += " AND applies_to_admins = 1"

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
		usr << "<span class='danger'>Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin.</span>"
		return

	if(ban_number > 1)
		usr << "<span class='danger'>Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin.</span>"
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		usr << "<span class='danger'>Database update failed due to a ban ID mismatch. Contact the database admin.</span>"
		return

	DB_ban_unban_by_id(ban_id)

/datum/admins/proc/DB_ban_edit(banid = null, param = null)

	if(!check_rights(R_BAN))
		return

	if(!isnum(banid) || !istext(param))
		usr << "Cancelled"
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey, TIMESTAMPDIFF(MINUTE,bantime,expiration_time), reason FROM [format_table_name("ban")] WHERE id = [banid]")
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

	reason = sanitizeSQL(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text
				value = sanitizeSQL(value)
				if(!value)
					usr << "Cancelled"
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("ban")] SET reason = '[value]', edits = CONCAT(edits,'- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><BR>') WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]",1)
		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					usr << "Cancelled"
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("ban")] SET edits = CONCAT(edits,'- [eckey] changed ban duration from [duration] to [value]<br>'), expiration_time = DATE_ADD(bantime, INTERVAL [value] MINUTE) WHERE id = [banid]")
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

/datum/admins/proc/DB_ban_unban_by_id(id)

	if(!check_rights(R_BAN))
		return

	var/sql = "SELECT ckey FROM [format_table_name("ban")] WHERE id = [id]"

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
		usr << "<span class='danger'>Database update failed due to a ban id not being present in the database.</span>"
		return

	if(ban_number > 1)
		usr << "<span class='danger'>Database update failed due to multiple bans having the same ID. Contact the database admin.</span>"
		return

	if(!src.owner || !istype(src.owner, /client))
		return

	var/unban_ckey = src.owner:ckey
	var/unban_computerid = src.owner:computer_id
	var/unban_ip = src.owner:address

	var/sql_update = "UPDATE [format_table_name("ban")] SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[unban_ckey]', unbanned_computerid = '[unban_computerid]', unbanned_ip = '[unban_ip]' WHERE id = [id]"
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


/datum/admins/proc/DB_ban_panel(playerckey = null, adminckey = null)
	if(!usr.client)
		return

	if(!check_rights(R_BAN))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	output += "<td width='35%' align='center'>"
	output += "<h1>Banning panel</h1>"
	output += "</td>"

	output += "<td width='65%' align='center' bgcolor='#f9f9f9'>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<table width='100%'><tr>"
	output += "<td><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td>"
	output += "<td><b>Applies to admins:</b> <input type='checkbox' name='dbbanappliestoadmins'></tr>"
	output += "<tr><td><b>IP:</b> <input type='text' name='dbbanaddip'></td>"
	output += "<td><b>Computer id:</b> <input type='text' name='dbbanaddcid'></td></tr>"
	output += "<tr><td><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>Server</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in nonhuman_positions)
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("traitor","changeling","operative","revolutionary", "gangster","cultist","wizard", "abductor", "alien candidate"))
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("posibrain", "drone", "emote", "OOC", "appearance"))
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

		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, bantime, reason, job, TIMESTAMPDIFF(MINUTE,bantime,expiration_time), expiration_time, ckey, a_ckey, applies_to_admins, unbanned, unbanned_ckey, unbanned_datetime, edits FROM [format_table_name("ban")] WHERE 1 [playersearch] [adminsearch] ORDER BY bantime DESC")
		select_query.Execute()

		while(select_query.NextRow())
			var/banid = select_query.item[1]
			var/bantime = select_query.item[2]
			var/reason = select_query.item[3]
			var/job = select_query.item[4]
			var/duration = select_query.item[5]
			var/expiration = select_query.item[6]
			var/ckey = select_query.item[7]
			var/ackey = select_query.item[8]
			var/applies_to_admins = select_query.item[9]
			var/unbanned = select_query.item[10]
			var/unbanckey = select_query.item[11]
			var/unbantime = select_query.item[12]
			var/edits = select_query.item[13]

			var/lcolor = blcolor
			var/dcolor = bdcolor
			if(unbanned)
				lcolor = ulcolor
				dcolor = udcolor

			var/title = ""
			var/smallprint = ""
			if(!expiration)
				title = "<font color='red'><b>PERMABAN</b></font>"
			else
				title = "<b>TEMPBAN</b>"
				smallprint = "<br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
			if(job)
				title = "<b>JOB</b> " + title
				smallprint = "<br><font size='2'>([job])</font>" + smallprint
			if(applies_to_admins)
				title = "<b>ADMIN</b> " + title
			var/typedesc = title + smallprint

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