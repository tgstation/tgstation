/datum/admins/proc/citaTopic(href, href_list)
	if(href_list["makementor"])
		makeMentor(href_list["makementor"])
	else if(href_list["removementor"])
		removeMentor(href_list["removementor"])

/datum/admins/proc/makeMentor(ckey)
	if(!usr.client)
		return
	if (!check_rights(0))
		return
	if(!ckey)
		return
	var/client/C = GLOB.directory[ckey]
	if(C)
		if(check_rights_for(C, R_ADMIN,0))
			to_chat(usr, "<span class='danger'>The client chosen is an admin! Cannot mentorize.</span>")
			return
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_get_mentor = SSdbcore.NewQuery("SELECT id FROM [format_table_name("mentor")] WHERE ckey = '[ckey]'")
		if(query_get_mentor.NextRow())
			to_chat(usr, "<span class='danger'>[ckey] is already a mentor.</span>")
			return
		var/datum/DBQuery/query_add_mentor = SSdbcore.NewQuery("INSERT INTO `[format_table_name("mentor")]` (`id`, `ckey`) VALUES (null, '[ckey]')")
		if(!query_add_mentor.warn_execute())
			return
		var/datum/DBQuery/query_add_admin_log = SSdbcore.NewQuery("INSERT INTO `[format_table_name("admin_log")]` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Added new mentor [ckey]');")
		if(!query_add_admin_log.warn_execute())
			return
	else
		to_chat(usr, "<span class='danger'>Failed to establish database connection. The changes will last only for the current round.</span>")
	new /datum/mentors(ckey)
	to_chat(usr, "<span class='adminnotice'>New mentor added.</span>")

/datum/admins/proc/removeMentor(ckey)
	if(!usr.client)
		return
	if (!check_rights(0))
		return
	if(!ckey)
		return
	var/client/C = GLOB.directory[ckey]
	if(C)
		if(check_rights_for(C, R_ADMIN,0))
			to_chat(usr, "<span class='danger'>The client chosen is an admin, not a mentor! Cannot de-mentorize.</span>")
			return
		C.remove_mentor_verbs()
		C.mentor_datum = null
		GLOB.mentors -= C
	if(SSdbcore.Connect())
		var/datum/DBQuery/query_remove_mentor = SSdbcore.NewQuery("DELETE FROM [format_table_name("mentor")] WHERE ckey = '[ckey]'")
		if(!query_remove_mentor.warn_execute())
			return
		var/datum/DBQuery/query_add_admin_log = SSdbcore.NewQuery("INSERT INTO `[format_table_name("admin_log")]` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Removed mentor [ckey]');")
		if(!query_add_admin_log.warn_execute())
			return
	else
		to_chat(usr, "<span class='danger'>Failed to establish database connection. The changes will last only for the current round.</span>")
	to_chat(usr, "<span class='adminnotice'>Mentor removed.</span>")