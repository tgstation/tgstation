#define MAX_ADMIN_BANS_PER_ADMIN 1
#define MAX_ADMIN_BANS_PER_HEADMIN 3

//Either pass the mob you wish to ban in the 'banned_mob' attribute, or the banckey, banip and bancid variables. If both are passed, the mob takes priority! If a mob is not passed, banckey is the minimum that needs to be passed! banip and bancid are optional.
/datum/admins/proc/DB_ban_record(bantype, mob/banned_mob, duration = -1, reason, job = "", banckey = null, banip = null, bancid = null)

	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/bantype_pass = 0
	var/bantype_str
	var/maxadminbancheck	//Used to limit the number of active bans of a certein type that each admin can give. Used to protect against abuse or mutiny.
	var/announceinirc		//When set, it announces the ban in irc. Intended to be a way to raise an alarm, so to speak.
	var/blockselfban		//Used to prevent the banning of yourself.
	var/kickbannedckey		//Defines whether this proc should kick the banned person, if they are connected (if banned_mob is defined).
							//some ban types kick players after this proc passes (tempban, permaban), but some are specific to db_ban, so
							//they should kick within this proc.
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
			blockselfban = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
			blockselfban = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1
		if(BANTYPE_ADMIN_PERMA)
			bantype_str = "ADMIN_PERMABAN"
			duration = -1
			bantype_pass = 1
			maxadminbancheck = 1
			announceinirc = 1
			blockselfban = 1
			kickbannedckey = 1
		if(BANTYPE_ADMIN_TEMP)
			bantype_str = "ADMIN_TEMPBAN"
			bantype_pass = 1
			maxadminbancheck = 1
			announceinirc = 1
			blockselfban = 1
			kickbannedckey = 1
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
		else
			computerid = banned_mob.computer_id
			ip = banned_mob.lastKnownIP
	else if(banckey)
		ckey = ckey(banckey)
		computerid = bancid
		ip = banip

	var/datum/DBQuery/query_add_ban_get_ckey = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ckey = '[ckey]'")
	if(!query_add_ban_get_ckey.warn_execute())
		return
	if(!query_add_ban_get_ckey.NextRow())
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			if(alert(usr, "[ckey] has not been seen before, are you sure you want to create a ban for them?", "Unknown ckey", "Yes", "No", "Cancel") != "Yes")
				return

	var/a_ckey
	var/a_computerid
	var/a_ip

	if(istype(owner))
		a_ckey = owner.ckey
		a_computerid = owner.computer_id
		a_ip = owner.address

	if(blockselfban)
		if(a_ckey == ckey)
			to_chat(usr, "<span class='danger'>You cannot apply this ban type on yourself.</span>")
			return

	var/who
	for(var/client/C in GLOB.clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in GLOB.admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"

	reason = sanitizeSQL(reason)

	if(maxadminbancheck)
		var/datum/DBQuery/query_check_adminban_amt = SSdbcore.NewQuery("SELECT count(id) AS num FROM [format_table_name("ban")] WHERE (a_ckey = '[a_ckey]') AND (bantype = 'ADMIN_PERMABAN'  OR (bantype = 'ADMIN_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query_check_adminban_amt.warn_execute())
			return
		if(query_check_adminban_amt.NextRow())
			var/adm_bans = text2num(query_check_adminban_amt.item[1])
			var/max_bans = MAX_ADMIN_BANS_PER_ADMIN
			if (check_rights(R_PERMISSIONS, FALSE))
				max_bans = MAX_ADMIN_BANS_PER_HEADMIN
			if(adm_bans >= max_bans)
				to_chat(usr, "<span class='danger'>You already logged [max_bans] admin ban(s) or more. Do not abuse this function!</span>")
				return
	if(!computerid)
		computerid = "0"
	if(!ip)
		ip = "0.0.0.0"
	var/sql = "INSERT INTO [format_table_name("ban")] (`bantime`,`server_ip`,`server_port`,`round_id`,`bantype`,`reason`,`job`,`duration`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]', '[GLOB.round_id]', '[bantype_str]', '[reason]', '[job]', [(duration)?"[duration]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[ckey]', '[computerid]', INET_ATON('[ip]'), '[a_ckey]', '[a_computerid]', INET_ATON('[a_ip]'), '[who]', '[adminwho]')"
	var/datum/DBQuery/query_add_ban = SSdbcore.NewQuery(sql)
	if(!query_add_ban.warn_execute())
		return
	to_chat(usr, "<span class='adminnotice'>Ban saved to database.</span>")
	var/msg = "[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database."
	message_admins(msg,1)
	var/datum/admin_help/AH = admin_ticket_log(ckey, msg)

	if(announceinirc)
		send2irc("BAN ALERT","[a_ckey] applied a [bantype_str] on [ckey]")

	if(kickbannedckey)
		if(AH)
			AH.Resolve()	//with prejudice
		if(banned_mob && banned_mob.client && banned_mob.client.ckey == banckey)
			qdel(banned_mob.client)
	return 1

/datum/admins/proc/DB_ban_unban(ckey, bantype, job = "")

	if(!check_rights(R_BAN))
		return

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
			if(BANTYPE_ADMIN_PERMA)
				bantype_str = "ADMIN_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_ADMIN_TEMP)
				bantype_str = "ADMIN_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
			if(BANTYPE_ANY_JOB)
				bantype_str = "ANYJOB"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now() ) )"
	else if(bantype_str == "ANYJOB")
		bantype_sql = "(bantype = 'JOB_PERMABAN' OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "bantype = '[bantype_str]'"

	var/sql = "SELECT id FROM [format_table_name("ban")] WHERE ckey = '[ckey]' AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	if(job)
		sql += " AND job = '[job]'"

	if(!SSdbcore.Connect())
		return

	var/ban_id
	var/ban_number = 0 //failsafe

	var/datum/DBQuery/query_unban_get_id = SSdbcore.NewQuery(sql)
	if(!query_unban_get_id.warn_execute())
		return
	while(query_unban_get_id.NextRow())
		ban_id = query_unban_get_id.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='danger'>Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin.</span>")
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='danger'>Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin.</span>")
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		to_chat(usr, "<span class='danger'>Database update failed due to a ban ID mismatch. Contact the database admin.</span>")
		return

	DB_ban_unban_by_id(ban_id)

/datum/admins/proc/DB_ban_edit(banid = null, param = null)

	if(!check_rights(R_BAN))
		return

	if(!isnum(banid) || !istext(param))
		to_chat(usr, "Cancelled")
		return

	var/datum/DBQuery/query_edit_ban_get_details = SSdbcore.NewQuery("SELECT ckey, duration, reason FROM [format_table_name("ban")] WHERE id = [banid]")
	if(!query_edit_ban_get_details.warn_execute())
		return

	var/eckey = usr.ckey	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason

	if(query_edit_ban_get_details.NextRow())
		pckey = query_edit_ban_get_details.item[1]
		duration = query_edit_ban_get_details.item[2]
		reason = query_edit_ban_get_details.item[3]
	else
		to_chat(usr, "Invalid ban id. Contact the database admin")
		return

	reason = sanitizeSQL(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text
				value = sanitizeSQL(value)
				if(!value)
					to_chat(usr, "Cancelled")
					return

			var/datum/DBQuery/query_edit_ban_reason = SSdbcore.NewQuery("UPDATE [format_table_name("ban")] SET reason = '[value]', edits = CONCAT(edits,'- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><BR>') WHERE id = [banid]")
			if(!query_edit_ban_reason.warn_execute())
				return
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]",1)
		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					to_chat(usr, "Cancelled")
					return

			var/datum/DBQuery/query_edit_ban_duration = SSdbcore.NewQuery("UPDATE [format_table_name("ban")] SET duration = [value], edits = CONCAT(edits,'- [eckey] changed ban duration from [duration] to [value]<br>'), expiration_time = DATE_ADD(bantime, INTERVAL [value] MINUTE) WHERE id = [banid]")
			if(!query_edit_ban_duration.warn_execute())
				return
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]",1)
		if("unban")
			if(alert("Unban [pckey]?", "Unban?", "Yes", "No") == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				to_chat(usr, "Cancelled")
				return
		else
			to_chat(usr, "Cancelled")
			return

/datum/admins/proc/DB_ban_unban_by_id(id)

	if(!check_rights(R_BAN))
		return

	var/sql = "SELECT ckey FROM [format_table_name("ban")] WHERE id = [id]"

	if(!SSdbcore.Connect())
		return

	var/ban_number = 0 //failsafe

	var/pckey
	var/datum/DBQuery/query_unban_get_ckey = SSdbcore.NewQuery(sql)
	if(!query_unban_get_ckey.warn_execute())
		return
	while(query_unban_get_ckey.NextRow())
		pckey = query_unban_get_ckey.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='danger'>Database update failed due to a ban id not being present in the database.</span>")
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='danger'>Database update failed due to multiple bans having the same ID. Contact the database admin.</span>")
		return

	if(!istype(owner))
		return

	var/unban_ckey = owner.ckey
	var/unban_computerid = owner.computer_id
	var/unban_ip = owner.address

	var/sql_update = "UPDATE [format_table_name("ban")] SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[unban_ckey]', unbanned_computerid = '[unban_computerid]', unbanned_ip = INET_ATON('[unban_ip]') WHERE id = [id]"
	var/datum/DBQuery/query_unban = SSdbcore.NewQuery(sql_update)
	if(!query_unban.warn_execute())
		return
	message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.",1)

/client/proc/DB_ban_panel()
	set category = "Admin"
	set name = "Banning Panel"
	set desc = "Edit admin permissions"

	if(!holder)
		return

	holder.DB_ban_panel()


/datum/admins/proc/DB_ban_panel(playerckey = null, adminckey = null, page = 0)
	if(!usr.client)
		return

	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
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
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "<option value='[BANTYPE_ADMIN_PERMA]'>ADMIN PERMABAN</option>"
	output += "<option value='[BANTYPE_ADMIN_TEMP]'>ADMIN TEMPBAN</option>"
	output += "</select></td>"
	output += "<td><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td><b>IP:</b> <input type='text' name='dbbanaddip'></td>"
	output += "<td><b>Computer id:</b> <input type='text' name='dbbanaddcid'></td></tr>"
	output += "<tr><td><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in get_all_jobs())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in GLOB.nonhuman_positions)
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("traitor","changeling","operative","revolutionary", "gangster","cultist","wizard"))
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
		playerckey = sanitizeSQL(ckey(playerckey))
		adminckey = sanitizeSQL(ckey(adminckey))
		var/playersearch = ""
		var/adminsearch = ""
		if(playerckey)
			playersearch = "AND ckey = '[playerckey]' "
		if(adminckey)
			adminsearch = "AND a_ckey = '[adminckey]' "
		var/bancount = 0
		var/bansperpage = 15
		var/pagecount = 0
		page = text2num(page)
		var/datum/DBQuery/query_count_bans = SSdbcore.NewQuery("SELECT COUNT(id) FROM [format_table_name("ban")] WHERE 1 [playersearch] [adminsearch]")
		if(!query_count_bans.warn_execute())
			return
		if(query_count_bans.NextRow())
			bancount = text2num(query_count_bans.item[1])
		if(bancount > bansperpage)
			output += "<br><b>Page: </b>"
			while(bancount > 0)
				output+= "|<a href='?_src_=holder;[HrefToken()];dbsearchckey=[playerckey];dbsearchadmin=[adminckey];dbsearchpage=[pagecount]'>[pagecount == page ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
				bancount -= bansperpage
				pagecount++
			output += "|"
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
		var/limit = " LIMIT [bansperpage * page], [bansperpage]"
		var/datum/DBQuery/query_search_bans = SSdbcore.NewQuery("SELECT id, bantime, bantype, reason, job, duration, expiration_time, ckey, a_ckey, unbanned, unbanned_ckey, unbanned_datetime, edits FROM [format_table_name("ban")] WHERE 1 [playersearch] [adminsearch] ORDER BY bantime DESC[limit]")
		if(!query_search_bans.warn_execute())
			return

		while(query_search_bans.NextRow())
			var/banid = query_search_bans.item[1]
			var/bantime = query_search_bans.item[2]
			var/bantype  = query_search_bans.item[3]
			var/reason = query_search_bans.item[4]
			var/job = query_search_bans.item[5]
			var/duration = query_search_bans.item[6]
			var/expiration = query_search_bans.item[7]
			var/ckey = query_search_bans.item[8]
			var/ackey = query_search_bans.item[9]
			var/unbanned = query_search_bans.item[10]
			var/unbanckey = query_search_bans.item[11]
			var/unbantime = query_search_bans.item[12]
			var/edits = query_search_bans.item[13]

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
					typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];[HrefToken()];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
				if("JOB_PERMABAN")
					typedesc = "<b>JOBBAN</b><br><font size='2'>([job])"
				if("JOB_TEMPBAN")
					typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];[HrefToken()];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]"
				if("ADMIN_PERMABAN")
					typedesc = "<b>ADMIN PERMABAN</b>"
				if("ADMIN_TEMPBAN")
					typedesc = "<b>ADMIN TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];[HrefToken()];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"

			output += "<tr bgcolor='[dcolor]'>"
			output += "<td align='center'>[typedesc]</td>"
			output += "<td align='center'><b>[ckey]</b></td>"
			output += "<td align='center'>[bantime]</td>"
			output += "<td align='center'><b>[ackey]</b></td>"
			output += "<td align='center'>[(unbanned) ? "" : "<b><a href=\"byond://?src=\ref[src];[HrefToken()];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
			output += "</tr>"
			output += "<tr bgcolor='[lcolor]'>"
			output += "<td align='center' colspan='5'><b>Reason: [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];[HrefToken()];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
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
