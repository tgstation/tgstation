/datum/migration/sqlite/ss13_prefs/_005
	id = 5
	name = "Add Parallax Speed"

/datum/migration/sqlite/ss13_prefs/_005/up()
	if(!hasColumn("client","parallax_speed"))
		return execute("ALTER TABLE `client` ADD COLUMN parallax_speed INTEGER DEFAULT 2")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_005/down()
	if(hasColumn("client","parallax_speed"))
		return execute("ALTER TABLE `client` DROP COLUMN parallax_speed")
	return TRUE
