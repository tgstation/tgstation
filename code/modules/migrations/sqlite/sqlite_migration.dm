/datum/migration/sqlite
	dbms="sqlite"

	var/dbfilename=""
/datum/migration/sqlite/New(var/datum/migration_controller/sqlite/mc)
	..(mc)
	if(istype(mc))
		dbfilename=mc.dbfilename

/datum/migration/sqlite/query(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		world.log << sql
		world.log << "Error in [package]#[id]: [Q.ErrorMsg()]"
		return null
	var/list/O=list()
	while(Q.NextRow())
		O += list(Q.GetRowData())
	if(!O.len)
		return null
	return O

/datum/migration/sqlite/hasResult(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		world.log << sql
		world.log << "Error in [package]#[id]: [Q.ErrorMsg()]"
		return FALSE
	return Q.NextRow()

/datum/migration/sqlite/execute(var/sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		world.log << sql
		world.log << "Error in [package]#[id]: [Q.ErrorMsg()]"
		return FALSE
	return TRUE

/datum/migration/sqlite/hasTable(var/tableName)
	var/exists = hasResult("SELECT name FROM sqlite_master WHERE type='table' AND name='[tableName]';")
	return exists

/datum/migration/sqlite/hasColumn(var/tableName, var/columnName)
	for(var/list/row in query("PRAGMA table_info([tableName])")) // Can't be turned into a SELECT.
		if(row["name"]==columnName)
			return TRUE
	return FALSE