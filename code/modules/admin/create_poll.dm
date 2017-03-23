/client/proc/create_poll()
	set name = "Create Poll"
	set category = "Special Verbs"
	if(!check_rights(R_PERMISSIONS))
		return
	if(!dbcon.IsConnected())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/returned = create_poll_function()
	if(returned)
		var/DBQuery/query_check_option = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE pollid = [returned]")
		if(!query_check_option.warn_execute())
			return
		if(query_check_option.NextRow())
			var/DBQuery/query_log_get = dbcon.NewQuery("SELECT polltype, question, adminonly FROM [format_table_name("poll_question")] WHERE id = [returned]")
			if(!query_log_get.warn_execute())
				return
			if(query_log_get.NextRow())
				var/polltype = query_log_get.item[1]
				var/question = query_log_get.item[2]
				var/adminonly = text2num(query_log_get.item[3])
				log_admin("[key_name(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"] - Question: [question]")
				message_admins("[key_name_admin(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"]<br>Question: [question]")
		else
			to_chat(src, "Poll question created without any options, poll will be deleted.")
			var/DBQuery/query_del_poll = dbcon.NewQuery("DELETE FROM [format_table_name("poll_question")] WHERE id = [returned]")
			if(!query_del_poll.warn_execute())
				return

/client/proc/create_poll_function()
	var/polltype = input("Choose poll type.","Poll Type") in list("Single Option","Text Reply","Rating","Multiple Choice", "Instant Runoff Voting")|null
	var/choice_amount = 0
	switch(polltype)
		if("Single Option")
			polltype = POLLTYPE_OPTION
		if("Text Reply")
			polltype = POLLTYPE_TEXT
		if("Rating")
			polltype = POLLTYPE_RATING
		if("Multiple Choice")
			polltype = POLLTYPE_MULTI
			choice_amount = input("How many choices should be allowed?","Select choice amount") as num|null
			if(!choice_amount)
				return
		if ("Instant Runoff Voting")
			polltype = POLLTYPE_IRV
		else
			return 0
	var/starttime = SQLtime()
	var/endtime = input("Set end time for poll as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than starting time for obvious reasons.", "Set end time", SQLtime()) as text
	if(!endtime)
		return
	endtime = sanitizeSQL(endtime)
	var/DBQuery/query_validate_time = dbcon.NewQuery("SELECT STR_TO_DATE('[endtime]','%Y-%c-%d %T')")
	if(!query_validate_time.warn_execute())
		return
	if(query_validate_time.NextRow())
		endtime = query_validate_time.item[1]
		if(!endtime)
			to_chat(src, "Datetime entered is invalid.")
			return
	var/DBQuery/query_time_later = dbcon.NewQuery("SELECT TIMESTAMP('[endtime]') < NOW()")
	if(!query_time_later.warn_execute())
		return
	if(query_time_later.NextRow())
		var/checklate = text2num(query_time_later.item[1])
		if(checklate)
			to_chat(src, "Datetime entered is not later than current server time.")
			return
	var/adminonly
	switch(alert("Admin only poll?",,"Yes","No","Cancel"))
		if("Yes")
			adminonly = 1
		if("No")
			adminonly = 0
		else
			return
	var/dontshow
	switch(alert("Hide poll results from tracking until completed?",,"Yes","No","Cancel"))
		if("Yes")
			dontshow = 1
		if("No")
			dontshow = 0
		else
			return
	var/sql_ckey = sanitizeSQL(ckey)
	var/question = input("Write your question","Question") as message|null
	if(!question)
		return
	question = sanitizeSQL(question)
	var/DBQuery/query_polladd_question = dbcon.NewQuery("INSERT INTO [format_table_name("poll_question")] (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip, dontshow) VALUES ('[polltype]', '[starttime]', '[endtime]', '[question]', '[adminonly]', '[choice_amount]', '[sql_ckey]', INET_ATON('[address]'), '[dontshow]')")
	if(!query_polladd_question.warn_execute())
		return
	if(polltype == POLLTYPE_TEXT)
		log_admin("[key_name(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"] - Question: [question]")
		message_admins("[key_name_admin(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"]<br>Question: [question]")
		return
	var/pollid = 0
	var/DBQuery/query_get_id = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE question = '[question]' AND starttime = '[starttime]' AND endtime = '[endtime]' AND createdby_ckey = '[sql_ckey]' AND createdby_ip = INET_ATON('[address]')")
	if(!query_get_id.warn_execute())
		return
	if(query_get_id.NextRow())
		pollid = query_get_id.item[1]
	var/add_option = 1
	while(add_option)
		var/option = input("Write your option","Option") as message|null
		if(!option)
			return pollid
		option = sanitizeSQL(option)
		var/percentagecalc = 1
		if (polltype != POLLTYPE_IRV)
			switch(alert("Calculate option results as percentage?",,"Yes","No","Cancel"))
				if("Yes")
					percentagecalc = 1
				if("No")
					percentagecalc = 0
				else
					return pollid
		var/minval = 0
		var/maxval = 0
		var/descmin = ""
		var/descmid = ""
		var/descmax = ""
		if(polltype == POLLTYPE_RATING)
			minval = input("Set minimum rating value.","Minimum rating") as num|null
			if(!minval)
				return pollid
			maxval = input("Set maximum rating value.","Maximum rating") as num|null
			if(!maxval)
				return pollid
			if(minval >= maxval)
				to_chat(src, "Minimum rating value can't be more than maximum rating value")
				return pollid
			descmin = input("Optional: Set description for minimum rating","Minimum rating description") as message|null
			if(descmin)
				descmin = sanitizeSQL(descmin)
			else if(descmin == null)
				return pollid
			descmid = input("Optional: Set description for median rating","Median rating description") as message|null
			if(descmid)
				descmid = sanitizeSQL(descmid)
			else if(descmid == null)
				return pollid
			descmax = input("Optional: Set description for maximum rating","Maximum rating description") as message|null
			if(descmax)
				descmax = sanitizeSQL(descmax)
			else if(descmax == null)
				return pollid
		var/DBQuery/query_polladd_option = dbcon.NewQuery("INSERT INTO [format_table_name("poll_option")] (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES ('[pollid]', '[option]', '[percentagecalc]', '[minval]', '[maxval]', '[descmin]', '[descmid]', '[descmax]')")
		if(!query_polladd_option.warn_execute())
			return pollid
		switch(alert(" ",,"Add option","Finish", "Cancel"))
			if("Add option")
				add_option = 1
			if("Finish")
				add_option = 0
			else
				return 0
	return pollid