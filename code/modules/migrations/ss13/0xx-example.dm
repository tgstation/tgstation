
/*
/datum/migration/mysql/ss13/_0x
	id = 0x
	name = "test"
	old_db_major = 0
	old_db_minor = 0
	new_db_major = 0
	new_db_minor = 0

/datum/migration/mysql/ss13/_0x/up()
	if(!..())
		return FALSE
	if(!hasTable(TABLE_NAME))
		return execute({"
			-- SQL HERE
			)
		"});
	else
		warning("skipping addition.")
		return FALSE

/datum/migration/mysql/ss13/_0x/down()
	if (!..())
		return FALSE
	if(hasTable(TABLE_NAME))
		return execute("-- SQL HERE");
	else
		warning("skipping drop")
		return FALSE
*/
