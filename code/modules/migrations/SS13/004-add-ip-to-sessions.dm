/datum/migration/mysql/ss13/_004
	id = 4
	name = "Add IP to Sessions"

/datum/migration/mysql/ss13/_004/up()
	if(!hasColumn("admin_sessions","IP"))
		return execute("ALTER TABLE admin_sessions ADD COLUMN `IP` VARCHAR(255) DEFAULT NULL;");
	else
		warning("IP column exists. Skipping addition.")
	return TRUE

/datum/migration/mysql/ss13/_004/down()
	if(hasColumn("admin_sessions","IP"))
		return execute("ALTER TABLE admin_sessions DROP COLUMN `IP`;");
	else
		warning("IP column does not exist. Skipping drop.")
	return TRUE