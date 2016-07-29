/datum/migration/mysql/ss13/_005
	id = 5
	name = "Modernize Library"

/datum/migration/mysql/ss13/_005/up()
	if(!hasColumn("library","ckey"))
		return execute("ALTER TABLE library ADD COLUMN `ckey` VARCHAR(32) NULL;"); // Permit nulls, we interpret these as old values.
	else
		warning("ckey column exists. Skipping addition.")
	return TRUE

/datum/migration/mysql/ss13/_005/down()
	if(hasColumn("library","ckey"))
		return execute("ALTER TABLE library DROP COLUMN `ckey`;");
	else
		warning("ckey column does not exist. Skipping drop.")
	return TRUE