/datum/database_migration
	var/schema_version_major
	var/schema_version_minor

	var/failed = FALSE
	var/datum/DBQuery/query

/datum/database_migration/proc/Up()
	CRASH("Migration [type] does not implement Up()!")

/datum/database_migration/proc/Down()
	CRASH("Migration [type] does not implement Down()!")

/datum/database_migration/proc/M(sql)
	if(failed)
		return
	_ExecuteDirect(sql)

/datum/database_migration/proc/_ExecuteDirect(sql)
	query.SetQuery(sql)
	if(!query.Execute(TRUE, FALSE))
		ErrorOut(sql)
	query.Close()

/datum/database_migration/proc/ErrorOut(sql)
	failed = TRUE
	log_sql("Migration [type] ([schema_version_major].[schema_version_minor]) failed! [sql ? "Query: [sql], " : ""]Message: [query.ErrorMsg()]")

/datum/database_migration/proc/Run(datum/DBQuery/query, down = FALSE)
	var/local_transaction = !query
	if(local_transaction)
		query = SSdbcore.NewQuery()
	src.query = query

	var/log_message = "[down ? "Una" : "A"]pplying [type] ([schema_version_major].[schema_version_minor])..."
	log_world(log_message)
	log_sql(log_message)

	if(local_transaction)
		M("BEGIN TRANSACTION")

	if(down)
		Down()
		if(schema_version_major > 4 || schema_version_minor > 7)
			M("DELETE FROM [format_table_name("schema_revision")] WHERE major=[schema_version_major] AND minor=[schema_version_minor]")
	else
		Up()
		M("INSERT INTO [format_table_name("schema_revision")] (major, minor) VALUES ([schema_version_major], [schema_version_minor])")

	if(local_transaction)
		M("COMMIT")
		if(failed)
			_ExecuteDirect("ROLLBACK")
		qdel(query)

	return !failed
