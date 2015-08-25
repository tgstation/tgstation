var/global/datum/migration_controller/mysql/migration_controller_mysql = null

/datum/migration_controller/mysql
	id="mysql"
	var/DBConnection/db

/datum/migration_controller/mysql/setup()
	if(!dbcon || !istype(dbcon) || !dbcon.IsConnected())
		testing("Something wrong with dbcon.")
		return FALSE
	var/DBQuery/Q = dbcon.NewQuery()
	if(!Q)
		testing("Something wrong with dbcon.NewQuery()")
		return FALSE
	Q.Close()
	testing("MySQL is okay")
	db = dbcon
	return TRUE

/datum/migration_controller/mysql/createMigrationTable()
	var/tableSQL = {"
CREATE TABLE IF NOT EXISTS [TABLE_NAME] (
	pkgID VARCHAR(15) PRIMARY KEY, -- Implies NOT NULL
	version INT(11) NOT NULL
);
	"}
	execute(tableSQL)

/datum/migration_controller/mysql/query(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration_controller/proc/query() called tick#: [world.time]")
	var/DBQuery/query = execute(sql)

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration_controller/mysql/hasResult(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration_controller/proc/hasResult() called tick#: [world.time]")
	var/DBQuery/query = execute(sql)

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration_controller/mysql/execute(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration_controller/proc/execute() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	query.Execute()
	return query

/datum/migration_controller/mysql/hasTable(var/tableName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration_controller/proc/hasTable() called tick#: [world.time]")
	return hasResult("SHOW TABLES LIKE '[tableName]")