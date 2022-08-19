/datum/admins/proc/trophy_manager()
	set name = "Trophy Manager"
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return
	var/datum/trophy_manager/ui = new(usr)
	ui.ui_interact(usr)

/// Trophy Admin Management Panel
/datum/trophy_manager

/datum/trophy_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/trophy_manager/ui_close(mob/user)
	qdel(src)

/datum/trophy_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrophyAdminPanel")
		ui.open()

/datum/trophy_manager/ui_data(mob/user)
	. = list()
	.["trophies"] = SSpersistence.trophy_ui_data()
