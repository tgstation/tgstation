/datum/migration/ss13/_005
	id = 5
	name = "Modernize Library"

/datum/migration/ss13/_005/up()
	if(!hasColumn("library","ckey"))
		execute("ALTER TABLE library ADD COLUMN `ckey` VARCHAR(32) NOT NULL DEFAULT '\[Unknown\]';");
	else
		warning("ckey column exists. Skipping addition.")

/datum/migration/ss13/_005/down()
	if(hasColumn("library","ckey"))
		execute("ALTER TABLE library DROP COLUMN `ckey`;");
	else
		warning("ckey column does not exist. Skipping drop.")