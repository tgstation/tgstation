// Panel for achievement management
/datum/achievement_admin_panel
	var/list/orphaned_keys

/datum/achievement_admin_panel/proc/reload_data()
	if(!SSachievements.achievements_enabled)
		return
	orphaned_keys = SSachievements.get_orphaned_keys()

/datum/achievement_admin_panel/ui_data()
	. = list()
	var/list/orphaned_only = list()
	var/list/archived_only = list()
	for(var/key in orphaned_keys)
		if(orphaned_keys[key] == ACHIEVEMENT_ARCHIVED_VERSION)
			archived_only += key
		else
			orphaned_only += key
	.["orphaned_keys"] = orphaned_only
	.["archived_keys"] = archived_only

/datum/achievement_admin_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/achievement_admin_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AchievementsAdminPanel")
		ui.open()

/datum/achievement_admin_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch (action)
		if("archive")
			var/achievement_key = params["key"]
			archive_achievement(achievement_key)
			reload_data()
			return TRUE
		if("cleanup_orphan")
			var/achievement_key = params["key"]
			cleanup_outdated_achievement(achievement_key)
			reload_data()
			return TRUE



/datum/achievement_admin_panel/proc/cleanup_outdated_achievement(achievement_key)
	// ensure key is actually orphaned just in case
	if(!(achievement_key in orphaned_keys))
		return
	log_admin("[key_name_admin(usr)] has deleted orphaned achievement metadata for key [achievement_key].")
	message_admins("[key_name_admin(usr)] has deleted orphaned achievement metadata for key [achievement_key].")
	SSdbcore.QuerySelect(list(
		SSdbcore.NewQuery("DELETE FROM [format_table_name("achievement_metadata")] WHERE achievement_key = :key", list("key" = achievement_key)),
		SSdbcore.NewQuery("DELETE FROM [format_table_name("achievements")] WHERE achievement_key = :key", list("key" = achievement_key)),
	), warn = TRUE, qdel = TRUE)

/datum/achievement_admin_panel/proc/archive_achievement(achievement_key)
	// ensure key is actually orphaned just in case
	if(!(achievement_key in orphaned_keys))
		return
	log_admin("[key_name_admin(usr)] has archived orphaned achievement metadata for key [achievement_key].")
	message_admins("[key_name_admin(usr)] has archived orphaned achievement metadata for key [achievement_key].")
	SSdbcore.QuerySelect(list(
		SSdbcore.NewQuery("UPDATE [format_table_name("achievement_metadata")] SET achievement_version = :version WHERE achievement_key = :key", list("key" = achievement_key, "version" = ACHIEVEMENT_ARCHIVED_VERSION)),
	), warn = TRUE, qdel = TRUE)

ADMIN_VERB(achievements_cleanup, R_ADMIN, "Achievements Admin Panel", "View achievements management panel.", ADMIN_CATEGORY_MAIN)
	var/datum/achievement_admin_panel/panel = new /datum/achievement_admin_panel()
	panel.reload_data()
	panel.ui_interact(user.mob)
