var/global/datum/migration_controller/sqlite/migration_controller_sqlite = null

//#define DEBUG_SQLITE_MIGCON

#ifdef DEBUG_SQLITE_MIGCON
#define _DEBUG(a,b) testing("\[Migrations\] (sqlite) - [a](): [b]")
#else
#define _DEBUG(a,b)
#endif

/datum/migration_controller/sqlite
	id = "sqlite"

	var/dbfilename = "" // Name of DB
	var/empty_dbfilename = ""

/datum/migration_controller/sqlite/New(var/dbfile, var/cleandbfile)
	dbfilename=dbfile
	empty_dbfilename=cleandbfile
	..()

/datum/migration_controller/sqlite/setup()
	if(!fexists("players2.sqlite") && fexists("players2_empty.sqlite"))
		fcopy("players2_empty.sqlite", "players2.sqlite")
	return TRUE

/datum/migration_controller/sqlite/createMigrationTable()
	var/tableSQL = {"
CREATE TABLE IF NOT EXISTS [TABLE_NAME] (
	pkgID TEXT NOT NULL,
	version INTEGER NOT NULL,
	PRIMARY KEY(pkgID)
);
	"}
	execute(tableSQL)

/datum/migration_controller/sqlite/execute(var/sql)
	_DEBUG("execute",sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		warning("Error in migration controller ([id]): [Q.ErrorMsg()]")
		return FALSE
	return TRUE

/datum/migration_controller/sqlite/query(var/sql)
	_DEBUG("query",sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		warning("Error in migration controller ([id]): [Q.ErrorMsg()]")
		return null
	var/list/O=list()
	while(Q.NextRow())
		O += list(Q.GetRowData())
	return O

/datum/migration_controller/sqlite/hasResult(var/sql)
	_DEBUG("hasResult",sql)
	var/database/query/Q = new()
	Q.Add(sql)
	if(!Q.Execute(dbfilename))
		warning("Error in migration controller ([id]): [Q.ErrorMsg()]")
		return FALSE
	if (Q.NextRow())
		return TRUE
	return FALSE

/datum/migration_controller/sqlite/hasTable(var/tableName)
	var/exists = hasResult("SELECT name FROM sqlite_master WHERE type='table' AND name='[tableName]';")
	return exists

#ifdef DEBUG_SQLITE_MIGCON
#undef _DEBUG
#undef DEBUG_SQLITE_MIGCON
#endif
