/**
 * A simple system to update the database automatically.
 *
 * @author Rob "N3X15" Nelson
 */

/datum/migration
	var/name=""    // Displayed name of the migration.
	var/package="" // Package ID of this migration. (15 chars max)
	var/id=1       // Revision ID of this migration, incremented for each change.

	var/DBConnection/db = null // Database connection

/datum/migration/proc/up()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/up() called tick#: [world.time]")
	// Make your changes here.
	return TRUE

/datum/migration/proc/down()
    //writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/down() called tick#: [world.time]")
    // Undo your changes here (for rollbacks)
    return TRUE

// Helpers
/datum/migration/proc/query(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/query() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration/proc/hasResult(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasResult() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration/proc/execute(var/sql)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/execute() called tick#: [world.time]")
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE
	return TRUE

/datum/migration/proc/hasTable(var/tableName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasTable() called tick#: [world.time]")
	return hasResult("SHOW TABLES LIKE '[tableName]'")

/datum/migration/proc/hasColumn(var/tableName, var/columnName)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/migration/proc/hasColumn() called tick#: [world.time]")
	return hasResult("SHOW COLUMNS FROM [tableName] LIKE '[columnName]'")