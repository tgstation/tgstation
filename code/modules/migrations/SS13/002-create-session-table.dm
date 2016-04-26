/datum/migration/mysql/ss13/_002
	id = 2
	name = "Create Session Table"

/datum/migration/mysql/ss13/_002/up()
	var/sql={"
CREATE TABLE IF NOT EXISTS admin_sessions (
	`sessID` CHAR(36) PRIMARY KEY,
	`ckey` VARCHAR(255),
	`expires` DATETIME
);
	"}
	return execute(sql)

/datum/migration/mysql/ss13/_002/down()
	return execute("DROP TABLE IF EXISTS admin_sessions;");
