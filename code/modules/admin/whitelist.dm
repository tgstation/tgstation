#define WHITELISTFILE "config/whitelist.txt"

GLOBAL_LIST(whitelist)
GLOBAL_PROTECT(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in world.file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.whitelist += line

	if(!GLOB.whitelist.len)
		GLOB.whitelist = null

/proc/check_whitelist(var/ckey)
	if(!GLOB.whitelist)
		return FALSE
	. = (ckey in GLOB.whitelist)

#undef WHITELISTFILE

/client/proc/sql_query()
	set name = "SQL query"
	set category = "Debug"

	if(holder)
		if(ckey != "einlinet") //дебаг у каждого второго педального долбоеба так что просто нет
			usr << "GTFO"
			return

		var/query_text = input("SQL query")

		var/DBQuery/query = dbcon.NewQuery("[query_text]")
		query.Execute()

		log_admin("[key_name(usr)] executed following SQL query: [query_text]")
		message_admins("[key_name(usr)] executed following SQL query: [query_text]")

		//пока только такой обрезок
		//когда нибудь закончу
