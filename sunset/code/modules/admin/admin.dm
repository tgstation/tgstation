/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="can you even see verb descriptions anywhere?"
	set name="Toggle LOOC"
	toggle_looc()
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] toggled LOOC.")
	SSblackbox.record_feedback("admin_toggle","Toggle LOOC|[GLOB.looc_allowed]")

/datum/admins/proc/toggleloocdead()
	set category = "Server"
	set desc = "seriously, why do we even bother"
	set name = "Toggle Dead LOOC"
	GLOB.dlooc_allowed = !(GLOB.dlooc_allowed)
	log_admin("[key_name(usr)] toggled Dead LOOC.")
	message_admins("[key_name_admin(usr)] toggled Dead LOOC.")
	SSblackbox.record_feedback("admin_toggle","Toggle Dead LOOC|[GLOB.dlooc_allowed]")