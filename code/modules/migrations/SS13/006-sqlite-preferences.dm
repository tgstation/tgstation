/datum/migration/ss13/sqlite
	id = 6
	name = "languages n shit son"

/datum/migration/ss13/sqlite/up()
	var/sqlitedb = ("players2.sqlite")
	var/list/columns = list()
	if(columns && columns.len)
		var/database/query/check = new
		var/database/query/q = new
		var/database/query/insert = new
		check.Add("SHOW COLUMNS FROM players LIKE [list2text(columns," OR LIKE ")]")
		if(check.Execute(sqlitedb))
			for(var/column in columns)
				if(!q.GetColumn(column))
					insert.Add("ALTER TABLE players ADD [column] VARCHAR(255)")
					insert.Execute(sqlitedb)
					if(insert.Error()) warning("Error inserting column [column], [insert.Error()] - [insert.ErrorMsg()]")
					insert.Clear()