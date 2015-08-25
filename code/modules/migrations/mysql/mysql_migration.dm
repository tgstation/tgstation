/datum/migration/mysql
	var/DBConnection/db
	dbms="mysql"

/datum/migration/mysql/New(var/datum/migration_controller/mysql/mc)
	..(mc)
	if(istype(mc))
		db=mc.db

/datum/migration/mysql/query(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/query() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration/mysql/hasResult(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasResult() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration/mysql/execute(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/execute() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE
	return TRUE

/datum/migration/mysql/hasTable(var/tableName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasTable() called tick#: [world.time]")
	return hasResult("SHOW TABLES LIKE '[tableName]'")

/datum/migration/mysql/hasColumn(var/tableName, var/columnName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasColumn() called tick#: [world.time]")
	return hasResult("SHOW COLUMNS FROM [tableName] LIKE '[columnName]'")