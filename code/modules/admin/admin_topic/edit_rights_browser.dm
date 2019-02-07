/datum/datum_topic/admins_topic/editrightsbrowser
	keyword= "editrightsbrowser"
	log = FALSE

/datum/datum_topic/admins_topic/editrightsbrowser/Run(list/input,var/datum/admins/A)
	edit_admin_permissions(0)


/datum/datum_topic/admins_topic/editrights_browserlog
	keyword= "editrightsbrowserlog"
	log = FALSE

/datum/datum_topic/admins_topic/editrights_browserlog/Run(list/input,var/datum/admins/A)
	edit_admin_permissions(1, input["editrightstarget"], input["editrightsoperation"], input["editrightspage"])

/datum/datum_topic/admins_topic/editrightsbrowsermanage
	keyword= "editrightsbrowsermanage"
	log = FALSE

/datum/datum_topic/admins_topic/editrightsbrowsermanage/Run(list/input,var/datum/admins/A)
	if(input["editrightschange"])
		A.change_admin_rank(ckey(input["editrightschange"]), input["editrightschange"], TRUE)
	else if(input["editrightsremove"])
		A.remove_admin(ckey(input["editrightsremove"]), input["editrightsremove"], TRUE)
	else if(input["editrightsremoverank"])
		A.remove_rank(input["editrightsremoverank"])
	A.edit_admin_permissions(2)

/datum/datum_topic/admins_topic/editrights
	keyword= "editrights"
	log = FALSE

/datum/datum_topic/admins_topic/editrights/Run(list/input,var/datum/admins/A)
	A.edit_rights_topic(input)