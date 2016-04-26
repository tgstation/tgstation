/**
 * A simple system to update the database automatically.
 *
 * @author Rob "N3X15" Nelson
 */

/datum/migration
	var/name=""    // Displayed name of the migration.
	var/package="" // Package ID of this migration. (15 chars max)
	var/dbms=""    // Name of the DBMS (mysql, sqlite)
	var/id=1       // Revision ID of this migration, incremented for each change.

	var/datum/migration_controller/MC // Database connection

/datum/migration/New(var/datum/migration_controller/mc)
	MC=mc

/datum/migration/proc/up()
	// Make your changes here.
	return TRUE

/datum/migration/proc/down()
    // Undo your changes here (for rollbacks)
    return TRUE

// Helpers
/datum/migration/proc/query(var/sql)
	return

/datum/migration/proc/hasResult(var/sql)
	return

/datum/migration/proc/execute(var/sql)
	return

/datum/migration/proc/hasTable(var/tableName)
	return

/datum/migration/proc/hasColumn(var/tableName, var/columnName)
	return