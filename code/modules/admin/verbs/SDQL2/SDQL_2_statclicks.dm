/obj/effect/statclick/SDQL2_action

/obj/effect/statclick/SDQL2_action/Click()
	if(!usr.client?.holder)
		message_admins("[key_name_admin(usr)] non-holder clicked on a statclick! ([src])")
		usr.log_message("non-holder clicked on a statclick! ([src])", LOG_ADMIN)
		return
	var/datum/sdql2_query/Q = target
	Q.action_click()

/obj/effect/statclick/SDQL2_delete

/obj/effect/statclick/SDQL2_delete/Click()
	if(!usr.client?.holder)
		message_admins("[key_name_admin(usr)] non-holder clicked on a statclick! ([src])")
		usr.log_message("non-holder clicked on a statclick! ([src])", LOG_ADMIN)
		return
	var/datum/sdql2_query/Q = target
	Q.delete_click()

/obj/effect/statclick/sdql2_vv_all
	name = "VIEW VARIABLES"

/obj/effect/statclick/sdql2_vv_all/Click()
	if(!usr.client?.holder)
		message_admins("[key_name_admin(usr)] non-holder clicked on a statclick! ([src])")
		usr.log_message("non-holder clicked on a statclick! ([src])", LOG_ADMIN)
		return
	usr.client.debug_variables(GLOB.sdql2_queries)
