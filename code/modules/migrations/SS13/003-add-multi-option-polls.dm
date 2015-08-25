/datum/migration/mysql/ss13/_003
	id = 3
	name = "Add Multi-Option Polls"

/datum/migration/mysql/ss13/_003/up()
	if(!hasColumn("erro_poll_question","multiplechoiceoptions"))
		return execute("ALTER TABLE erro_poll_question ADD COLUMN `multiplechoiceoptions` int(2) DEFAULT NULL;")
	else
		warning("multiplechoiceoptions column exists. Skipping addition.")
	return TRUE

/datum/migration/mysql/ss13/_003/down()
	if(hasColumn("erro_poll_question","multiplechoiceoptions"))
		return execute("ALTER TABLE erro_poll_question DROP COLUMN `multiplechoiceoptions`;")
	else
		warning("multiplechoiceoptions column does not exist. Skipping drop.")
	return TRUE