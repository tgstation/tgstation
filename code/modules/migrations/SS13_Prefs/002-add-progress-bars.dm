/datum/migration/sqlite/ss13_prefs/_002
	id = 2
	name = "Add Progress Bars"

/datum/migration/sqlite/ss13_prefs/_002/up()
	if(!hasColumn("client","progress_bars"))
		return execute("ALTER TABLE `client` ADD COLUMN progress_bars INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_002/down()
	if(hasColumn("client","progress_bars"))
		return execute("ALTER TABLE `client` DROP COLUMN progress_bars")
	return TRUE
