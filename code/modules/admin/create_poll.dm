/client/proc/create_poll()
	set name = "Create Poll"
	set category = "Special Verbs"
	if(!check_rights(R_PERMISSIONS))	return
	if(!dbcon.IsConnected())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/polltype = input("Choose poll type.","Poll Type") in list("Single Option","Text Reply","Rating","Multiple Choice")
	var/choice_amount = 0
	switch(polltype)
		if("Single Option")
			polltype = "OPTION"
		if("Text Reply")
			polltype = "TEXT"
		if("Rating")
			polltype = "NUMVAL"
		if("Multiple Choice")
			polltype = "MULTICHOICE"
			choice_amount = input("How many choices should be allowed?","Select choice amount") as num
	var/starttime = SQLtime()
	var/endtime = input("Set end time for poll as format YYYY-MM-DD HH:MM:SS. All times in server time. HH:MM:SS is optional and 24-hour. Must be later than starting time for obvious reasons.", "Set end time", SQLtime()) as text
	if(!endtime)
		return
	endtime = sanitizeSQL(endtime)
	var/DBQuery/query_validate_time = dbcon.NewQuery("SELECT STR_TO_DATE('[endtime]','%Y-%c-%d %T')")
	if(!query_validate_time.Execute())
		var/err = query_validate_time.ErrorMsg()
		log_game("SQL ERROR validating endtime. Error : \[[err]\]\n")
		return
	if(query_validate_time.NextRow())
		endtime = query_validate_time.item[1]
		if(!endtime)
			to_chat(src, "Datetime entered is invalid.")
			return
	var/DBQuery/query_time_later = dbcon.NewQuery("SELECT DATE('[endtime]') < NOW()")
	if(!query_time_later.Execute())
		var/err = query_time_later.ErrorMsg()
		log_game("SQL ERROR comparing endtime to NOW(). Error : \[[err]\]\n")
		return
	if(query_time_later.NextRow())
		var/checklate = text2num(query_time_later.item[1])
		if(checklate)
			src << "Datetime entered is not later than current server time."
			return
	var/adminonly
	switch(alert("Admin only poll?",,"Yes","No","Cancel"))
		if("Yes")
			adminonly = 1
		if("No")
			adminonly = 0
		else
			return
	var/sql_ckey = sanitizeSQL(ckey)
	var/question = input("Write your question","Question") as message
	if(!question)
		return
	question = sanitizeSQL(question)
	var/DBQuery/query_polladd_question = dbcon.NewQuery("INSERT INTO erro_poll_question (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip) VALUES ('[polltype]', '[starttime]', '[endtime]', '[question]', '[adminonly]', '[choice_amount]', '[sql_ckey]', '[address]')")
	if(!query_polladd_question.Execute())
		var/err = query_polladd_question.ErrorMsg()
		log_game("SQL ERROR adding new poll question to table. Error : \[[err]\]\n")
		return
	var/pollid = 0
	var/DBQuery/query_get_id = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE question = '[question]' AND starttime = '[starttime]' AND endtime = '[endtime]' AND createdby_ckey = '[sql_ckey]' AND createdby_ip = '[address]'")
	if(!query_get_id.Execute())
		var/err = query_get_id.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_question table. Error : \[[err]\]\n")
		return
	if(query_get_id.NextRow())
		pollid = query_get_id.item[1]
	if(polltype == "TEXT")
		return
	var/add_option = 1
	while(add_option)
		var/option = input("Write your option","Option") as message
		if(!option)
			return
		option = sanitizeSQL(option)
		var/percentagecalc
		switch(alert("Calculate option results as percentage?",,"Yes","No","Cancel"))
			if("Yes")
				percentagecalc = 1
			if("No")
				percentagecalc = 0
			else
				return
		var/minval = 0
		var/maxval = 0
		var/descmin = ""
		var/descmid = ""
		var/descmax = ""
		if(polltype == "NUMVAL")
			minval = input("Set minimum rating value.","Minimum rating") as num
			if(!minval)
				return
			maxval = input("Set maximum rating value.","Maximum rating") as num
			if(!maxval)
				return
			if(minval >= maxval)
				src << "Minimum rating value can't be more than maximum rating value"
				return
			descmin = input("Optional: Set description for minimum rating","Minimum rating description") as message
			if(descmin)
				descmin = sanitizeSQL(descmin)
			descmid = input("Optional: Set description for median rating","Median rating description") as message
			if(descmid)
				descmid = sanitizeSQL(descmid)
			descmax = input("Optional: Set description for maximum rating","Maximum rating description") as message
			if(descmax)
				descmax = sanitizeSQL(descmax)
		var/DBQuery/query_polladd_option = dbcon.NewQuery("INSERT INTO erro_poll_option (pollid, text, percentagecalc, minval, maxval, descmin, descmid, descmax) VALUES ('[pollid]', '[option]', '[percentagecalc]', '[minval]', '[maxval]', '[descmin]', '[descmid]', '[descmax]')")
		if(!query_polladd_option.Execute())
			var/err = query_polladd_option.ErrorMsg()
			log_game("SQL ERROR adding new poll option to table. Error : \[[err]\]\n")
			return
		switch(alert(" ",,"Add option","Finish","Cancel"))
			if("Add option")
				add_option = 1
			if("Finish")
				add_option = 0
			else
				return