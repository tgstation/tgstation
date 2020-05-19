/datum/migration/mysql
	var/datum/controller/subsystem/dbcore/db
	var/new_db_major = 0
	var/new_db_minor = 0
	dbms="mysql"

/datum/migration/mysql/New(var/datum/migration_controller/mysql/mc)
	..(mc)
	if(istype(mc))
		db=mc.db

/datum/migration/mysql/query(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		log_sql("Error in [package]#[id]: [query.ErrorMsg()]")
		qdel(query)
		return FALSE

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	qdel(query)
	return rows

/datum/migration/mysql/hasResult(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		qdel(query)
		return FALSE

	if (query.NextRow())
		qdel(query)
		return TRUE
	qdel(query)
	return FALSE

/datum/migration/mysql/execute(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		log_sql("Error in [package]#[id]: [query.ErrorMsg()]")
		qdel(query)
		return FALSE
	qdel(query)
	return TRUE

/datum/migration/mysql/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[format_table_name(tableName)]'")

/datum/migration/mysql/hasColumn(var/tableName, var/columnName)
	return hasResult("SHOW COLUMNS FROM [format_table_name(tableName)] LIKE '[columnName]'")

/datum/migration/mysql/up()
	// Make your changes here.
	if(!execute("INSERT INTO [format_table_name("schema_revision")] (`major`, `minor`) VALUES ([new_db_major], [new_db_minor]);"))
		return FALSE
	return ..()

/datum/migration/mysql/down()
	// Undo your changes here (for rollbacks)
	if(!execute("DELETE FROM [format_table_name("schema_revision")] WHERE `major` = [new_db_major] AND `minor` = [new_db_minor];"))
		return FALSE
	return ..()
