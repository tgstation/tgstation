/datum/controller/subsystem/dbcore
	var/db_major_220 = 0
	var/db_minor_220 = 0
	var/schema_mismatch_220 = 0

/datum/controller/subsystem/dbcore/Initialize()
	. = ..()
	switch(schema_mismatch_220)
		if(1)
			message_admins("Database schema for BANDASTATION ([db_major_220].[db_minor_220]) doesn't match the latest schema version ([DB_MAJOR_VERSION_220].[DB_MINOR_VERSION_220]), this may lead to undefined behaviour or errors")
		if(2)
			message_admins("Could not get schema version for BANDASTATION from database")

/datum/controller/subsystem/dbcore/CheckSchemaVersion()
	. = ..()
	if(CONFIG_GET(flag/sql_enabled) && IsConnected())
		var/datum/db_query/query_db_version = NewQuery("SELECT major, minor FROM [format_table_name("schema_revision_220")] ORDER BY date DESC LIMIT 1")
		query_db_version.Execute()
		if(query_db_version.NextRow())
			db_major_220 = text2num(query_db_version.item[1])
			db_minor_220 = text2num(query_db_version.item[2])
			if(db_major_220 != DB_MAJOR_VERSION_220 || db_minor_220 != DB_MINOR_VERSION_220)
				schema_mismatch_220 = 1 // flag admin message about mismatch
				log_sql("Database schema for BANDASTATION ([db_major_220].[db_minor_220]) doesn't match the latest schema version ([DB_MAJOR_VERSION_220].[DB_MINOR_VERSION_220]), this may lead to undefined behaviour or errors")
		else
			schema_mismatch_220 = 2 //flag admin message about no schema version
			log_sql("Could not get schema version for BANDASTATION from database")
		qdel(query_db_version)
