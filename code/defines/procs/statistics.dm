proc/sql_poll_players()
	if(!sqllogging)
		return
	var/playercount = 0
	for(var/mob/M in world)
		if(M.client)
			playercount += 1
	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during player polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO population (playercount, time) VALUES ([playercount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during player polling. Error : \[[err]\]\n")
	dbcon.Disconnect()


proc/sql_poll_admins()
	if(!sqllogging)
		return
	var/admincount = 0
	for (var/mob/M in world)
		if(M && M.client && M.client.holder && M.client.authenticated)
			admincount += 1
	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during admin polling. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO population (admincount, time) VALUES ([admincount], '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during admin polling. Error : \[[err]\]\n")
	dbcon.Disconnect()

proc/sql_report_round_start()
	// TODO
	if(!sqllogging)
		return
proc/sql_report_round_end()
	// TODO
	if(!sqllogging)
		return

proc/sql_report_karma(var/mob/spender, var/mob/receiver, var/isnegative = 1)
	if(!sqllogging)
		return
	var/sqlspendername = spender.name
	var/sqlspenderkey = spender.key
	var/sqlreceivername = receiver.name
	var/sqlreceiverkey = receiver.key
	var/sqlreceiverrole = "None"
	var/sqlreceiverspecial = "None"
	var/sqlisnegative = "TRUE"

	if(isnegative)
		sqlisnegative = "TRUE"
	else
		sqlisnegative = "FALSE"

	var/sqlspenderip = spender.client.address

	if(receiver.mind)
		if(receiver.mind.special_role)
			sqlreceiverspecial = receiver.mind.special_role
		if(receiver.mind.assigned_role)
			sqlreceiverrole = receiver.mind.assigned_role

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during karma logging. Failed to connect.")
	else
		var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO karma (spendername, spenderkey, receivername, receiverkey, receiverrole, receiverspecial, isnegative, spenderip, time) VALUES ('[sqlspendername]', '[sqlspenderkey]', '[sqlreceivername]', '[sqlreceiverkey]', '[sqlreceiverrole]', '[sqlreceiverspecial]', [sqlisnegative], '[sqlspenderip]', '[sqltime]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during karma logging. Error : \[[err]\]\n")


		query = dbcon.NewQuery("SELECT * FROM karmatotals WHERE byondkey='[receiver.key]'")
		query.Execute()

		var/karma
		var/id
		while(query.NextRow())
			id = query.item[1]
			karma = text2num(query.item[3])
		if(karma == null)
			if(isnegative)
				karma = -1
			else
				karma = 1
			query = dbcon.NewQuery("INSERT INTO karmatotals (byondkey, karma) VALUES ('[receiver.key]', [karma])")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (adding new key). Error : \[[err]\]\n")
		else
			if(isnegative && sqlreceiverspecial != "None") // Toss out negative karma applied to traitors/wizards/etc.
				dbcon.Disconnect()
				return
			if(isnegative)
				karma -= 1
			else
				karma += 1

			query = dbcon.NewQuery("UPDATE karmatotals SET karma=[karma] WHERE id=[id]")
			if(!query.Execute())
				var/err = query.ErrorMsg()
				log_game("SQL ERROR during karmatotal logging (updating existing entry). Error : \[[err]\]\n")
	dbcon.Disconnect()


proc/sql_report_death(var/mob/living/carbon/human/H)
	if(!sqllogging)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = T.loc
	var/podname = placeofdeath.name

	var/sqlname = dd_replacetext(H.real_name, "'", "''")
	var/sqlkey = dd_replacetext(H.key, "'", "''")
	var/sqlpod = dd_replacetext(podname, "'", "''")
	var/sqlspecial = dd_replacetext(H.mind.special_role, "'", "''")
	var/sqljob = dd_replacetext(H.mind.assigned_role, "'", "''")
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = dd_replacetext(H.lastattacker:real_name, "'", "''")
		lakey = dd_replacetext(H.lastattacker:key, "'", "''")
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
	//world << "INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.fireloss], [H.brainloss], [H.oxyloss])"
	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.fireloss], [H.brainloss], [H.oxyloss], '[coord]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
	dbcon.Disconnect()


proc/sql_report_cyborg_death(var/mob/living/silicon/robot/H)
	if(!sqllogging)
		return
	if(!H)
		return
	if(!H.key || !H.mind)
		return

	var/turf/T = H.loc
	var/area/placeofdeath = T.loc
	var/podname = placeofdeath.name

	var/sqlname = dd_replacetext(H.real_name, "'", "''")
	var/sqlkey = dd_replacetext(H.key, "'", "''")
	var/sqlpod = dd_replacetext(podname, "'", "''")
	var/sqlspecial = dd_replacetext(H.mind.special_role, "'", "''")
	var/sqljob = dd_replacetext(H.mind.assigned_role, "'", "''")
	var/laname
	var/lakey
	if(H.lastattacker)
		laname = dd_replacetext(H.lastattacker:real_name, "'", "''")
		lakey = dd_replacetext(H.lastattacker:key, "'", "''")
	var/sqltime = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/coord = "[H.x], [H.y], [H.z]"
	//world << "INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.fireloss], [H.brainloss], [H.oxyloss])"
	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		log_game("SQL ERROR during death reporting. Failed to connect.")
	else
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO death (name, byondkey, job, special, pod, tod, laname, lakey, gender, bruteloss, fireloss, brainloss, oxyloss, coord) VALUES ('[sqlname]', '[sqlkey]', '[sqljob]', '[sqlspecial]', '[sqlpod]', '[sqltime]', '[laname]', '[lakey]', '[H.gender]', [H.bruteloss], [H.fireloss], [H.brainloss], [H.oxyloss], '[coord]')")
		if(!query.Execute())
			var/err = query.ErrorMsg()
			log_game("SQL ERROR during death reporting. Error : \[[err]\]\n")
	dbcon.Disconnect()


proc/statistic_cycle()
	if(!sqllogging)
		return
	while(1)
		sql_poll_players()
		sleep(600)
		sql_poll_admins()
		sleep(6000) // Poll every ten minutes
