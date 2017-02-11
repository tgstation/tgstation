/proc/sql_poll_players()
	if(!config.sql_enabled)
		return
	var/playercount = 0
	for(var/mob/M in player_list)
		if(M.client)
			playercount += 1
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (playercount, time) VALUES ([playercount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during player polling. Error : \[[err]\]\n")


/proc/sql_poll_admins()
	if(!config.sql_enabled)
		return
	var/admincount = admins.len
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during admin polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("legacy_population")] (admincount, time) VALUES ([admincount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during admin polling. Error : \[[err]\]\n")

/proc/sql_report_round_start()
	// TODO
	if(!config.sql_enabled)
		return

/proc/sql_report_round_end()
	// TODO
	if(!config.sql_enabled)
		return

/proc/sql_report_death(mob/living/L)
	if(!config.sql_enabled)
		return
	if(!L)
		return
	if(!L.key || !L.mind)
		return

	var/turf/T = get_turf(L)
	var/area/placeofdeath = get_area(T.loc)
	var/podname = placeofdeath.name

	var/sqlname = sanitizeSQL(L.real_name)
	var/sqlkey = sanitizeSQL(L.key)
	var/sqlpod = sanitizeSQL(podname)
	var/sqlspecial = sanitizeSQL(L.mind.special_role)
	var/sqljob = sanitizeSQL(L.mind.assigned_role)
	var/laname
	var/lakey
	if(L.lastattacker)
		laname = sanitizeSQL(L.lastattacker:real_name)
		lakey = sanitizeSQL(L.lastattacker:key)
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[L.x], [L.y], [L.z]"
	var/map = MAP_NAME
	var/server = "[world.address]:[world.port]"
	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("death")] (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord, mapname, server) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[L.gender]', [L.getBruteLoss()], [L.getFireLoss()], [L.brainloss], [L.getOxyLoss()], '[coord]', '[map]', [server]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")

//This proc is used for feedback. It is executed at round end.
/proc/sql_commit_feedback()
	if(!blackbox)
		log_game("Round ended without a blackbox recorder. No feedback was sent to the database.")
		return

	//content is a list of lists. Each item in the list is a list with two fields, a variable name and a value. Items MUST only have these two values.
	var/list/datum/feedback_variable/content = blackbox.get_round_feedback()

	if(!content)
		log_game("Round ended without any feedback being generated. No feedback was sent to the database.")
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during feedback reporting. Failed to connect.")
	else

		var/DBQuery/max_query = dbcon.NewQuery("SELECT MAX(roundid) AS max_round_id FROM [format_table_name("feedback")]")
		max_query.Execute()

		var/newroundid

		while(max_query.NextRow())
			newroundid = max_query.item[1]

		if(!(isnum(newroundid)))
			newroundid = text2num(newroundid)

		if(isnum(newroundid))
			newroundid++
		else
			newroundid = 1

		for(var/datum/feedback_variable/item in content)
			var/variable = item.get_variable()
			var/value = item.get_value()

			var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("feedback")] (id, roundid, time, variable, value) VALUES (null, [newroundid], Now(), '[variable]', '[value]')")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during feedback reporting. Error : \[[err]\]\n")