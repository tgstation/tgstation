/datum/admins/proc/sunset_makeInfiltrators(datum/admins/sr)
	message_admins("[key_name(usr)] is creating an infiltration team...")
	if(sr.makeInfiltratorTeam())
		message_admins("[key_name(usr)] created an infiltration team.")
		log_admin("[key_name(usr)] created an infiltration team.")
	else
		message_admins("[key_name_admin(usr)] tried to create an infiltration team. Unfortunately, there were not enough candidates available.")
		log_admin("[key_name(usr)] failed to create an infiltration team.")

/datum/admins/proc/sunsetTopic(href, href_list)
	if(href_list["makeAntag"] == "infiltrator")
		sunset_makeInfiltrators(src)