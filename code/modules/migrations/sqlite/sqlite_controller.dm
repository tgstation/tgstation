var/global/datum/migration_controller/sqlite/migration_controller_sqlite = null

/datum/migration_controller/sqlite
	id = "sqlite"

	var/dbfilename = "" // Name of DB
	var/empty_dbfilename = ""

/datum/migration_controller/sqlite/execute(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	return Q.Execute(dbfilename)

/datum/migration_controller/sqlite/query(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		return null
	var/list/O=list()
	while(Q.NextRow())
		O += list(Q.GetRowData())
	if(!O.len)
		return null
	return O

/datum/migration_controller/sqlite/hasResult(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		return FALSE
	if (Q.NextRow())
		return TRUE
	return FALSE

/datum/migration_controller/sqlite/hasTable(var/tableName)
	return hasResult("SELECT name FROM sqlite_master WHERE type='[tableName]'")