/**
 * A simple system to update the database automatically.
 *
 * Migrations are grouped by packages and ordered by id.
 * All migrations of a given package are applied sequentially, id after id.
 * In order to see how and when, this is called check [/datum/migration_controller][the migration controller].
 * The code here is abstract. Concrete implementation depend on the database system you are using and how your byond game communicates with it.
 * Concrete implementation of migration datums can be found in "mysql_migration.dm".
 *
 * @author Rob "N3X15" Nelson
 */
/datum/migration
	/// Displayed name of the migration.
	var/name=""
	/// Package ID of this migration. (15 chars max) All migrations of a package are added subsequently.
	var/package=""
	/// Name of the DBMS you are updatng. Displayed in debug messages.
	var/dbms=""
	/// Revision ID of this migration, incremented for each change. Migrations are done in ascending order.
	var/id=1
	/// The controller which contains a connection to the database in order to perform SQL tasks.
	var/datum/migration_controller/MC

/datum/migration/New(var/datum/migration_controller/mc)
	MC=mc

/**
  * Make the changes.
  *
  * This proc is ran when the migration is applied.
  *
  */
/datum/migration/proc/up()
	return TRUE

/**
  * Undo the changes.
  *
  * This proc contains the code to be run when the migration is reverted.
  *
  */
/datum/migration/proc/down()
    return TRUE


/**
  * Helper procs.
  *
  * These procs are redefined in child types  to perform SQL operations depending on the system you are using. (MySQL, SQLite, etc.)
  *
  */


/**
  * SQL wrapper
  *
  * Executes a query and returns the rows if any as a list.
  * The query is qdeleted and the errors are logged.
  * * sql - SQL to run
  */
/datum/migration/proc/query(var/sql)
	return

/**
  * Checks if a query yields a result or not.
  * * sql - SQL to run
  */
/datum/migration/proc/hasResult(var/sql)
	return

/**
  * Execute SQL
  *
  * Executes a query and returns TRUE or FALSE depending on sucess.
  * The query is qdeleted and the errors are logged.
  * * sql - SQL to run
  */
/datum/migration/proc/execute(var/sql)
	return

/**
  * Checks if the database on which you are applying the migration contains this table or not.
  * * tableName - The name of that table.
  */
/datum/migration/proc/hasTable(var/tableName)
	return

/**
  * Checks if the table on which you are applying the migration contains this collum or not.
  * * tableName - The name of that table.
  * * columnName - The name of that column.
  */
/datum/migration/proc/hasColumn(var/tableName, var/columnName)
	return
