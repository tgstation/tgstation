/datum/datum_topic/admins_topic/editrightsbrowser
	keyword= "editrightsbrowser"
	log = FALSE

/datum/datum_topic/admins_topic/editrightsbrowser/Run(list/input)
	edit_admin_permissions(0)


/datum/datum_topic/admins_topic/editrights_browserlog
	keyword= "editrightsbrowserlog"
	log = FALSE

/datum/datum_topic/admins_topic/editrights_browserlog/Run(list/input)
	edit_admin_permissions(1, href_list["editrightstarget"], href_list["editrightsoperation"], href_list["editrightspage"])

/datum/datum_topic/admins_topic/editrightsbrowsermanage
	keyword= "editrightsbrowsermanage"
	log = FALSE

/datum/datum_topic/admins_topic/editrightsbrowsermanage/Run(list/input)
	if(href_list["editrightschange"])
		change_admin_rank(ckey(href_list["editrightschange"]), href_list["editrightschange"], TRUE)
	else if(href_list["editrightsremove"])
		remove_admin(ckey(href_list["editrightsremove"]), href_list["editrightsremove"], TRUE)
	else if(href_list["editrightsremoverank"])
		remove_rank(href_list["editrightsremoverank"])
	edit_admin_permissions(2)

/datum/datum_topic/admins_topic/editrights
	keyword= "editrights"
	log = FALSE

/datum/datum_topic/admins_topic/editrights/Run(list/input)
	edit_rights_topic(href_list)