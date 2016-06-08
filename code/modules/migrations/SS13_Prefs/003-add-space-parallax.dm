/datum/migration/sqlite/ss13_prefs/_003
	id = 3
	name = "Add Space Parallax"

/datum/migration/sqlite/ss13_prefs/_003/up()
	if(!hasColumn("client","space_parallax"))
		return execute("ALTER TABLE `client` ADD COLUMN space_parallax INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_003/down()
	if(hasColumn("client","space_parallax"))
		return execute("ALTER TABLE `client` DROP COLUMN space_parallax")
	return TRUE
