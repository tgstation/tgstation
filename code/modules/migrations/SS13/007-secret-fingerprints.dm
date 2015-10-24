/datum/migration/mysql/ss13/_007
	id = 7
	name = "Secret Fingerprints"

/datum/migration/mysql/ss13/_007/up()
	if(!hasColumn("erro_player","fingerprint"))
		return execute("ALTER TABLE erro_player ADD COLUMN `fingerprint` VARCHAR(255) NULL;"); // Permit nulls, we interpret these as old values.
	else
		warning("fingerprint column exists. Skipping addition.")
	if(!hasColumn("erro_connection_log","fingerprint"))
		return execute("ALTER TABLE erro_connection_log ADD COLUMN `fingerprint` VARCHAR(255) NULL;"); // Permit nulls, we interpret these as old values.
	else
		warning("fingerprint column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_007/down()
	if(hasColumn("erro_player","fingerprint"))
		return execute("ALTER TABLE erro_player DROP COLUMN `fingerprint`;");
	else
		warning("fingerprint column does not exist. Skipping drop.")
	if(hasColumn("erro_connection_log","fingerprint"))
		return execute("ALTER TABLE erro_connection_log DROP COLUMN `fingerprint`;");
	else
		warning("fingerprint column does not exist. Skipping drop.")

	return TRUE