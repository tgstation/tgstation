var/checked_for_inactives = 0
var/inactive_keys = "None<br>"

/client/proc/check_customitem_activity()
	set category = "Admin"
	set name = "Check activity of players with custom items"

	var/dat = "<b>Inactive players with custom items</b><br>"
	dat += "<br>"
	dat += "The list below contains players with custom items that have not logged\
	 in for the past two months, or have not logged in since this system was implemented.\
	 This system requires the feedback SQL database to be properly setup and linked.<br>"
	dat += "<br>"
	dat += "Populating this list is done automatically, but must be manually triggered on a per\
	 round basis. Populating the list may cause a lag spike, so use it sparingly.<br>"
	dat += "<hr>"
	if(checked_for_inactives)
		dat += inactive_keys
		dat += "<hr>"
		dat += "This system was implemented on March 1 2013, and the database a few days before that. Root server access is required to add or disable access to specific custom items.<br>"
	else
		dat += "<a href='?src=\ref[src];_src_=holder;populate_inactive_customitems=1'>Populate list (requires an active database connection)</a><br>"

	usr << browse(dat, "window=inactive_customitems;size=600x480")

/proc/populate_inactive_customitems_list(var/client/C)
	set background = 1

	if(checked_for_inactives)
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	//grab all ckeys associated with custom items
	var/list/ckeys_with_customitems = list()

	var/file = file2text("config/custom_items.txt")
	var/lines = text2list(file, "\n")

	for(var/line in lines)
		// split & clean up
		var/list/Entry = text2list(line, ":")
		for(var/i = 1 to Entry.len)
			Entry[i] = trim(Entry[i])

		if(Entry.len < 1)
			continue

		var/cur_key = Entry[1]
		if(!ckeys_with_customitems.Find(cur_key))
			ckeys_with_customitems.Add(cur_key)

	//run a query to get all ckeys inactive for over 2 months
	var/list/inactive_ckeys = list()
	if(ckeys_with_customitems.len)
		var/DBQuery/query_inactive = dbcon.NewQuery("SELECT ckey, lastseen FROM erro_player WHERE datediff(Now(), lastseen) > 60")
		query_inactive.Execute()
		while(query_inactive.NextRow())
			var/cur_ckey = query_inactive.item[1]
			//if the ckey has a custom item attached, output it
			if(ckeys_with_customitems.Find(cur_ckey))
				ckeys_with_customitems.Remove(cur_ckey)
				inactive_ckeys[cur_ckey] = "last seen on [query_inactive.item[2]]"

	//if there are ckeys left over, check whether they have a database entry at all
	if(ckeys_with_customitems.len)
		for(var/cur_ckey in ckeys_with_customitems)
			var/DBQuery/query_inactive = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ckey = '[cur_ckey]'")
			query_inactive.Execute()
			if(!query_inactive.RowCount())
				inactive_ckeys += cur_ckey

	if(inactive_ckeys.len)
		inactive_keys = ""
		for(var/cur_key in inactive_ckeys)
			if(inactive_ckeys[cur_key])
				inactive_keys += "<b>[cur_key]</b> - [inactive_ckeys[cur_key]]<br>"
			else
				inactive_keys += "[cur_key] - no database entry<br>"

	checked_for_inactives = 1
	if(C)
		C.check_customitem_activity()
