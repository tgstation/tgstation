// Call this proc thru advanced proccall to update your DB from the legacy APPEARANCE_ system to the JOB_ system
/proc/appearance_legacy_to_job()
	if(!establish_db_connection())
		usr << "<span class='userdanger'>Database connection failed. Unable to update legacy appearance bans.</span>"
		return

	usr << "<span class='userdanger'>Updating legacy appearance bans.</span>"
	var/DBQuery/query = dbcon.NewQuery("UPDATE [format_table_name("ban")] SET bantype='JOB_PERMABAN',job='appearance' WHERE bantype = 'APPEARANCE_PERMABAN'")
	query.Execute()
	usr << "<span class='userdanger'>Legacy appearance permabans updated.</span>"
	query = dbcon.NewQuery("UPDATE [format_table_name("ban")] SET bantype='JOB_TEMPBAN',job='appearance' WHERE bantype = 'APPEARANCE_TEMPBAN'")
	query.Execute()
	usr << "<span class='userdanger'>Legacy appearance tempbans updated.</span>"
