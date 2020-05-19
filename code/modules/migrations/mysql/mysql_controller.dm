GLOBAL_DATUM(migration_controller_mysql, /datum/migration_controller/mysql)

/datum/migration_controller/mysql
	id="mysql"
	var/datum/controller/subsystem/dbcore/db

/datum/migration_controller/mysql/setup()
	if(!SSdbcore || !istype(SSdbcore))
		warning("Something wrong with SSdbcore.")
		return FALSE
	if (!SSdbcore.Connect())
		warning("Couldn't establish connection to SSdbcore.")
		return FALSE
	var/datum/DBQuery/Q = SSdbcore.NewQuery()
	if(!Q)
		warning("Something wrong with SSdbcore.NewQuery()")
		return FALSE
	qdel(Q)
	//testing("MySQL is okay")
	db = SSdbcore
	return TRUE

/datum/migration_controller/mysql/createMigrationTable()
	var/tableSQL = {"
CREATE TABLE IF NOT EXISTS [format_table_name(TABLE_NAME)] (
	pkgID VARCHAR(15) PRIMARY KEY, -- Implies NOT NULL
	version INT(11) NOT NULL
);
	"}
	execute(tableSQL)

/datum/migration_controller/mysql/query(var/sql)
	var/datum/DBQuery/query = execute(sql)

	var/list/rows=list()
	while(query.NextRow())
		rows[++rows.len] = query.item.Copy()

	qdel(query)

	return rows

/datum/migration_controller/mysql/hasResult(var/sql)
	var/datum/DBQuery/query = execute(sql)
	if (query.NextRow())
		qdel(query)
		return TRUE
	qdel(query)
	return FALSE

/datum/migration_controller/mysql/execute(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	query.Execute()
	. = query

/datum/migration_controller/mysql/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[format_table_name(tableName)]'")
