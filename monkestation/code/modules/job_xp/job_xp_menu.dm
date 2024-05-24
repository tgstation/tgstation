/client
	var/datum/xp_menu/xp_menu

/datum/xp_menu
	var/client/owner

/datum/xp_menu/New(client/creator)
	. = ..()
	owner = creator

/datum/xp_menu/Destroy(force, ...)
	. = ..()
	owner = null

/datum/xp_menu/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XpMenu", "[owner.ckey]'s Job XP")
		ui.open()

/datum/xp_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/xp_menu/ui_close(mob/user)
	. = ..()
	if(!owner)
		return
	if(QDELETED(src))
		return
	QDEL_NULL(owner?.xp_menu)

/datum/xp_menu/ui_data(mob/user)
	var/list/data = list()

	data["job_levels"] = owner.prefs.job_level_list
	data["job_xp"] = owner.prefs.job_xp_list
	data["job_rewards_per_round"] = owner.prefs.job_rewards_per_round
	data["job_rewards_claimed"] = owner.prefs.job_rewards_claimed
	data["job_xp_for_level"] = owner.prefs.return_xp_for_nextlevel()

	return data
