GLOBAL_LIST_EMPTY(exp_to_update)
GLOBAL_PROTECT(exp_to_update)

// Admin Verbs
/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN))
		return
	var/list/msg = list()
	msg += "<html><head><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/C in GLOB.clients)
		msg += "<LI> - [key_name_admin(C)]: <A href='?_src_=holder;getplaytimewindow=\ref[C.mob]'>" + C.get_exp_living() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	src << browse(msg.Join(), "window=Player_playtime_check")

/datum/admins/proc/cmd_show_exp_panel(client/C)
	if(!C)
		to_chat(usr, "ERROR: Client not found.")
		return
	if(!check_rights(R_ADMIN))
		return
	var/list/body = list()
	body += "<html><head><title>Playtime for [C.key]</title></head><BODY><BR>Playtime:"
	body += C.get_exp_report()
	body += "<A href='?_src_=holder;toggleexempt=\ref[C]'>Toggle Exempt status</a>"
	body += "</BODY></HTML>"
	usr << browse(body.Join(), "window=playerplaytime[C.ckey];size=550x615")


/datum/admins/proc/toggle_exempt_status(client/C)
	if(!C)
		to_chat(usr, "ERROR: Client not found.")
		return
	if(!check_rights(R_ADMIN))
		return
	var/list/exp = C.prefs.exp
	if(exp[EXP_TYPE_EXEMPT] == 0)
		exp[EXP_TYPE_EXEMPT] = 1
	else
		exp[EXP_TYPE_EXEMPT] = 0
	message_admins("[key_name_admin(usr)] has [exp[EXP_TYPE_EXEMPT] ? "activated" : "deactivated"] job exp exempt status on [key_name_admin(C)]")
	update_exempt_db(C,exp[EXP_TYPE_EXEMPT])

// Procs


/datum/job/proc/required_playtime_remaining(client/C)
	if(!C)
		return 0
	if(!config.use_exp_tracking)
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!job_is_xp_locked(src.title))
		return 0
	if(config.use_exp_restrictions_admin_bypass && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/isexempt = C.prefs.exp[EXP_TYPE_EXEMPT]
	if(isexempt)
		return 0
	var/my_exp = calc_exp_type(C,get_exp_req_type())
	var/job_requirement = get_exp_req_amount()
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)

/datum/job/proc/get_exp_req_amount()
	if(title in GLOB.command_positions)
		if(config.use_exp_restrictions_heads_hours)
			return config.use_exp_restrictions_heads_hours * 60
	return exp_requirements

/datum/job/proc/get_exp_req_type()
	if(title in GLOB.command_positions)
		if(config.use_exp_restrictions_heads_department && exp_type_department)
			return exp_type_department
	return exp_type

/proc/job_is_xp_locked(jobtitle)
	if(!config.use_exp_restrictions_heads && jobtitle in GLOB.command_positions)
		return FALSE
	if(!config.use_exp_restrictions_other && !(jobtitle in GLOB.command_positions))
		return FALSE
	return TRUE

/proc/calc_exp_type(client/C,exptype)
	var/list/explist = C.prefs.exp.Copy()
	var/amount = 0
	var/list/typelist = GLOB.exp_jobsmap[exptype]
	if(!typelist)
		return -1
	for(var/job in typelist["titles"])
		if(job in explist)
			amount += explist[job]
	return amount

/client/proc/get_exp_report()
	if(!config.use_exp_tracking)
		return "Tracking is disabled in the server configuration file."
	var/list/play_records = prefs.exp
	if(!play_records.len)
		set_exp_from_db()
		play_records = prefs.exp
		if(!play_records.len)
			return "[key] has no records."
	var/return_text = list()
	return_text += "<UL>"
	var/list/exp_data = list()
	for(var/category in SSjob.name_occupations)
		if(play_records[category])
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/category in GLOB.exp_specialmap)
		if(play_records[category])
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(dep == EXP_TYPE_EXEMPT)
				return_text += "<LI>Exempt (all jobs auto-unlocked)</LI>"
			else if(exp_data[EXP_TYPE_LIVING] > 0)
				var/percentage = num2text(round(exp_data[dep]/exp_data[EXP_TYPE_LIVING]*100))
				return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] ([percentage]%)</LI>"
			else
				return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] </LI>"
	if(config.use_exp_restrictions_admin_bypass && check_rights(R_ADMIN, 0, mob))
		return_text += "<LI>Admin (all jobs auto-unlocked)</LI>"
	return_text += "</UL>"
	var/list/jobs_locked = list()
	var/list/jobs_unlocked = list()
	for(var/datum/job/job in SSjob.occupations)
		if(job.exp_requirements && job.exp_type)
			if(!job_is_xp_locked(job.title))
				continue
			else if(!job.required_playtime_remaining(mob.client))
				jobs_unlocked += job.title
			else
				var/xp_req = job.get_exp_req_amount()
				jobs_locked += "[job.title] [get_exp_format(text2num(calc_exp_type(src,job.get_exp_req_type())))] / [get_exp_format(xp_req)] as [job.get_exp_req_type()])"
	if(jobs_unlocked.len)
		return_text += "<BR><BR>Jobs Unlocked:<UL><LI>"
		return_text += jobs_unlocked.Join("</LI><LI>")
		return_text += "</LI></UL>"
	if(jobs_locked.len)
		return_text += "<BR><BR>Jobs Not Unlocked:<UL><LI>"
		return_text += jobs_locked.Join("</LI><LI>")
		return_text += "</LI></UL>"
	return return_text


/client/proc/get_exp_living()
	var/exp_living = text2num(prefs.exp[EXP_TYPE_LIVING])
	return get_exp_format(exp_living)

/proc/get_exp_format(expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "0h"

/proc/update_exp(mins, ann = FALSE)
	if(!SSdbcore.Connect())
		return -1
	for(var/client/L in GLOB.clients)
		if(L.is_afk())
			continue
		addtimer(CALLBACK(L,/client/proc/update_exp_list,mins,ann),10)
		CHECK_TICK

/proc/update_exp_db()
	SSdbcore.MassInsert(format_table_name("role_time"),GLOB.exp_to_update,TRUE)
	LAZYCLEARLIST(GLOB.exp_to_update)

//Manual incrementing/updating
/*
/client/proc/update_exp_client(minutes, announce_changes = FALSE)
	if(!src ||!ckey || !config.use_exp_tracking)
		return
	if(!SSdbcore.Connect())
		return -1
	var/datum/DBQuery/exp_read = SSdbcore.NewQuery("SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = '[sanitizeSQL(ckey)]'")
	if(!exp_read.Execute())
		var/err = exp_read.ErrorMsg()
		log_game("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		return -1
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0
	var/list/old_records = play_records.Copy()
	if(mob.stat != DEAD && mob.mind.assigned_role)
		play_records[EXP_TYPE_LIVING] += minutes
		if(announce_changes)
			to_chat(mob,"<span class='notice'>You got: [minutes] Living EXP!")
		for(var/job in SSjob.name_occupations)
			if(mob.mind.assigned_role == job)
				play_records[job] += minutes
				if(announce_changes)
					to_chat(mob,"<span class='notice'>You got: [minutes] [job] EXP!")
		if(mob.mind.special_role && !mob.mind.var_edited)
			play_records[EXP_TYPE_SPECIAL] += minutes
			if(announce_changes)
				to_chat(mob,"<span class='notice'>You got: [minutes] [mob.mind.special_role] EXP!")
	else if(isobserver(mob))
		play_records[EXP_TYPE_GHOST] += minutes
		if(announce_changes)
			to_chat(mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
	else if(minutes)	//Let "refresh" checks go through
		return
	prefs.exp = play_records

	for(var/jtype in play_records)
		if(play_records[jtype] != old_records[jtype])
			var jobname = jtype
			var time = play_records[jtype]
			var/datum/DBQuery/update_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("role_time")] (`ckey`, `job`, `minutes`) VALUES ('[sanitizeSQL(ckey)]', '[sanitizeSQL(jobname)]', '[sanitizeSQL(time)]') ON DUPLICATE KEY UPDATE minutes = VALUES(minutes)")
			if(!update_query.Execute())
				var/err = update_query.ErrorMsg()
				log_game("SQL ERROR during exp_update_client update. Error : \[[err]\]\n")
				message_admins("SQL ERROR during exp_update_client update. Error : \[[err]\]\n")
				return
*/
//resets a client's exp to what was in the db.
/client/proc/set_exp_from_db()
	if(!src ||!ckey || !config.use_exp_tracking)
		return
	if(!SSdbcore.Connect())
		return -1
	var/datum/DBQuery/exp_read = SSdbcore.NewQuery("SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = '[sanitizeSQL(ckey)]'")
	if(!exp_read.Execute())
		var/err = exp_read.ErrorMsg()
		log_game("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		return
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0

	prefs.exp = play_records


//toggles exempt status in the db
/proc/update_exempt_db(client/C, exempt = 0)
	if(!config.use_exp_tracking)
		return
	if(!SSdbcore.Connect())
		return -1

	var/datum/DBQuery/update_query = SSdbcore.NewQuery("INSERT INTO [format_table_name("role_time")] (`ckey`, `job`, `minutes`) VALUES ('[sanitizeSQL(C.ckey)]', '[EXP_TYPE_EXEMPT]', '[sanitizeSQL(exempt)]') ON DUPLICATE KEY UPDATE minutes = VALUES(minutes)")
	if(!update_query.Execute())
		var/err = update_query.ErrorMsg()
		log_game("SQL ERROR during exp_exempt update. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_exempt. Error : \[[err]\]\n")
		return

/client/proc/update_exp_list(minutes, announce_changes = FALSE)
	if(!src ||!ckey || !config.use_exp_tracking)
		return
	if(!SSdbcore.Connect())
		return -1
	var/datum/DBQuery/exp_read = SSdbcore.NewQuery("SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = '[sanitizeSQL(ckey)]'")
	if(!exp_read.Execute())
		var/err = exp_read.ErrorMsg()
		log_game("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		message_admins("SQL ERROR during exp_update_client read. Error : \[[err]\]\n")
		return -1
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0
	var/list/old_records = play_records.Copy()
	if(isliving(mob))
		if(mob.stat != DEAD)
			play_records[EXP_TYPE_LIVING] += minutes
			if(announce_changes)
				to_chat(mob,"<span class='notice'>You got: [minutes] Living EXP!")
			if(mob.mind.assigned_role)
				for(var/job in SSjob.name_occupations)
					if(mob.mind.assigned_role == job)
						play_records[job] += minutes
						if(announce_changes)
							to_chat(mob,"<span class='notice'>You got: [minutes] [job] EXP!")
				if(mob.mind.special_role && !mob.mind.var_edited)
					play_records[mob.mind.special_role] += minutes
					if(announce_changes)
						to_chat(mob,"<span class='notice'>You got: [minutes] [mob.mind.special_role] EXP!")
		else
			play_records[EXP_TYPE_GHOST] += minutes
			if(announce_changes)
				to_chat(mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
	else if(isobserver(mob))
		play_records[EXP_TYPE_GHOST] += minutes
		if(announce_changes)
			to_chat(mob,"<span class='notice'>You got: [minutes] Ghost EXP!")
	else if(minutes)	//Let "refresh" checks go through
		return
	prefs.exp = play_records

	for(var/jtype in play_records)
		if(play_records[jtype] != old_records[jtype])
			LAZYINITLIST(GLOB.exp_to_update)
			GLOB.exp_to_update.Add(list(list(
				"job" = "'[sanitizeSQL(jtype)]'",
				"ckey" = "'[sanitizeSQL(ckey)]'",
				"minutes" = play_records[jtype])))
	addtimer(CALLBACK(GLOBAL_PROC,.proc/update_exp_db),20,TIMER_OVERRIDE|TIMER_UNIQUE)