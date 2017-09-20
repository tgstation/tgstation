/client/proc/sql_query()
	set name = "SQL query"
	set category = "Debug"

	if(holder)
		if(ckey != "joctopus")
			usr << "GTFO"
			return

		var/query_text = input("SQL query")

		var/DBQuery/query = dbcon.NewQuery("[query_text]")
		query.Execute()

		log_admin("[key_name(usr)] executed following SQL query: [query_text]")
		message_admins("[key_name(usr)] executed following SQL query: [query_text]")