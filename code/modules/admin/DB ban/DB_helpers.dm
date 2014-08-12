
/*
Table needs to be a string corresponding to one of our SQL tables see the SQL.schema file for them.
*/

/proc/DB_get_ID_from_table(var/mob/M, var/table) //finds an ID corresponding to M, in table
	establish_db_connection()
	if(!dbcon.IsConnected())
		return "<span class='warning'>Database connection failed.</span>"

	if(!M || M.ckey)
		return "<span class='warning'>No Mob or Mob Ckey.</span>"

	if(!table)
		return "<span class='warning'>No table specified, This is a code issue.</span>"

	var/sql_find = "SELECT id FROM [table] WHERE ckey = '[M.ckey]'"
	var/id
	var/id_number = 0
	var/DBQuery/query = dbcon.NewQuery(sql_find)
	query.Execute()
	while(query.NextRow())
		id = query.item[1]
		id_number++

	if(id_number == 0) //No matches
		return "<span class='warning'>Database find failed due to no matches fitting the search criteria.</span>"

	if(id_number > 1) //Too many matches
		return "<span class='warning'>Database find failed due to multiple matches fitting the search criteria.</span>"

	if(istext(id))
		id = text2num(id)
	if(!isnum(id))
		return "<span class='warning'>Database find failed due to an ID mismatch. Contact the database admin.</span>"

	return id