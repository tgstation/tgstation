#define YOUNG 4


/client/proc/join_date_check(var/y,var/m,var/d)
		var/current_year = text2num(time2text(world.realtime, "YYYY"))
		var/current_month = text2num(time2text(world.realtime, "MM"))
		var/current_day = text2num(time2text(world.realtime, "DD"))
	var/warn = 0
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
		var/msg = "(IP: [address], ID: [computer_id]) is a new BYOND account made on [m]-[d]-[y]."
		message_admins("[key_name(src)] [msg]")
#undef YOUNG


/client/proc/findJoinDate()
	joindate = ""
	var/http[] = world.Export("http://byond.com/members/[src.ckey]?format=text")
	if(!http)
		world.log << "Failed to connect to byond age check for [src.ckey]"

	var/F = file2text(http["CONTENT"])
	if(F)
		var/regex/R = regex("joined = \"(\\d{4})-(\\d{2})-(\\d{2})\"")
		if(!R.Find(F))
			CRASH("Fail join")
		var/y = text2num(R.group[1])
		var/m = text2num(R.group[2])
		var/d = text2num(R.group[3])
		join_date_check(y,m,d)