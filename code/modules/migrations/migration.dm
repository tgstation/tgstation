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
	// Make your changes here.
	return TRUE

/datum/migration/proc/down()
    // Undo your changes here (for rollbacks)
    return TRUE

// Helpers
/datum/migration/proc/query(var/sql)
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration/proc/hasResult(var/sql)
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration/proc/execute(var/sql)
	var/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		return FALSE
	return TRUE

/datum/migration/proc/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[tableName]'")

/datum/migration/proc/hasColumn(var/tableName, var/columnName)
	return hasResult("SHOW COLUMNS FROM [tableName] LIKE '[columnName]'")