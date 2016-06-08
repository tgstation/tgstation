/datum/migration/sqlite/ss13_prefs/_004
	id = 4
	name = "Add Space Dust"

/datum/migration/sqlite/ss13_prefs/_004/up()
	if(!hasColumn("client","space_dust"))
		return execute("ALTER TABLE `client` ADD COLUMN space_dust INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_004/down()
	if(hasColumn("client","space_dust"))
		return execute("ALTER TABLE `client` DROP COLUMN space_dust")
	return TRUE
