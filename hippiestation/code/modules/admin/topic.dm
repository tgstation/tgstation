/datum/admins/proc/hippie_makeShadowling(datum/admins/sr)
	if(sr.makeShadowling())
		message_admins("[key_name(usr)] created a shadowling.")
		log_admin("[key_name(usr)] created a shadowling.")
	else
		message_admins("[key_name_admin(usr)] tried to create a shadowling. Unfortunately, there were no candidates available.")
		log_admin("[key_name(usr)] failed to create a shadowling.")

/datum/admins/proc/hippie_makeVampire(datum/admins/sr)
	if(sr.makeVampire())
		message_admins("[key_name(usr)] created a vampire.")
		log_admin("[key_name(usr)] created a vampire.")
	else
		message_admins("[key_name_admin(usr)] tried to create a vampire. Unfortunately, there were no candidates available.")
		log_admin("[key_name(usr)] failed to create a vampire.")

/datum/admins/proc/hippieTopic(href, href_list)
	if(href_list["makeAntag"] == "shadowling")
		hippie_makeShadowling(src)
	else if(href_list["makeAntag"] == "vampire")
		hippie_makeVampire(src)
	else if(href_list["makementor"])
		hippieMakeMentor(href_list["makementor"])
	else if(href_list["removementor"])
		hippieRemoveMentor(href_list["removementor"])

/datum/admins/proc/hippieMakeMentor(ckey)
	if(CONFIG_GET(flag/mentor_legacy_system))
		return
	if(!usr.client)
		return
	if (!check_rights(0))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!ckey)
		return
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
	to_chat(usr, "<span class='adminnotice'>New mentor added.</span>")

/datum/admins/proc/hippieRemoveMentor(ckey)
	if(CONFIG_GET(flag/mentor_legacy_system))
		return
	if(!usr.client)
		return
	if (!check_rights(0))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!ckey)
		return
	var/datum/DBQuery/query_remove_mentor = SSdbcore.NewQuery("DELETE FROM [format_table_name("mentor")] WHERE ckey = '[ckey]'")
	if(!query_remove_mentor.warn_execute())
		return
	var/datum/DBQuery/query_add_admin_log = SSdbcore.NewQuery("INSERT INTO `[format_table_name("admin_log")]` (`id` ,`datetime` ,`adminckey` ,`adminip` ,`log` ) VALUES (NULL , NOW( ) , '[usr.ckey]', '[usr.client.address]', 'Removed mentor [ckey]');")
	if(!query_add_admin_log.warn_execute())
		return
	to_chat(usr, "<span class='adminnotice'>Mentor removed.</span>")