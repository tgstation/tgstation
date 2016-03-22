#define YOUNG 4


/client/proc/join_date_check(var/jd)
	if (!current_year)
		current_year = text2num(time2text(world.realtime, "YYYY"))
	if (!current_month)
		current_month = text2num(time2text(world.realtime, "MM"))
	if (!current_day)
		current_day = text2num(time2text(world.realtime, "DD"))
	var/warn = 0
	var/regex/R = regex("joined = \"(\\d{4})-(\\d\\d)-(\\d\\d)\"")
	if(!R.Find(jd))
		CRASH("fail check")
	var/y = text2num(R.group[1])
	var/m = text2num(R.group[2])
	var/d = text2num(R.group[3])




//	var/y = text2num(copytext(jd, 1, 5))
//	var/m = text2num(copytext(jd, 6, 8))
//	var/d = text2num(copytext(jd, 9, 11))
	if (current_month == 1 && current_day <= YOUNG)
		if (y == current_year - 1 && m == 12 && d >= 31 - (YOUNG - current_day))
			warn = 1
		else if (y == current_year && m == 1)
			warn = 1
	else if (current_day <= YOUNG)
		if (y == current_year)
			if (m == current_month - 1 && d >= 28 - (YOUNG - current_day))
				warn = 1
			else if (m == current_month)
				warn = 1
	else if (y == current_year && m == current_month && d >= current_day - 4)
		warn = 1
	if (warn)
		var/msg = "(IP: [address], ID: [computer_id]) has a recent join date of [jd]."
		message_admins("[key_name(src)] [msg]")
#undef YOUNG


/client/proc/findJoinDate()
	joindate = ""
	var/http[] = world.Export("http://byond.com/members/[src.ckey]?format=text")
	if(!http)
		world.log << "Failed to connect"

	world.log << "http header"
	for(var/V in http)
		world.log << "[V] = [http[V]]"

	world.log << "\n"

	var/F = http["CONTENT"]
	if(F)
		world.log << html_encode(file2text(F))

		var/regex/R = regex("joined = \"(\\d{4}-\\d\\d-\\d\\d)\"")
		if(!R.Find(F))
			CRASH("Fail join")
		var/date = text2num(R.group[1])

		world.log << date
		join_date_check(date)
/*
	if(headers)
		if (!("CONTENT" in headers) || headers["STATUS"] != "200 OK")
			world.log << "ERROR export fail"
			return
		var/text = headers["CONTENT"]
		world.log << text
		//var/find = findtext(text, "joined = ")
		var/filter1 = copytext(text, findtext(text, "joined = ") + 1)
		world.log << filter1
		var/filter2 = copytext(filter1, 1)
		joindate = filter2
		world.log << filter2
		//join_date_check(joindate)
	return
*/
