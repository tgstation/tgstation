var/global/survival_streak_frozen = FALSE

/client/proc/freeze_streaks()
	set category = "Special Verbs"
	set name = "Freeze Survival Streak"
	set desc = "Survival streak features become frozen for this round. Players increasing or losing their streak will not be possible."

	if(!survival_streak_frozen && check_rights_for(src, R_FUN) && (alert(src, "This will freeze survival streak progress for all players this round, so that none of it actually gets saved. You will not be able to revert this. Are you sure?", "Freeze Survival Streak", "Yes", "No") == "Yes"))
		survival_streak_frozen = TRUE
		log_admin("[key_name(src)] froze survival streaks for this round.")
		message_admins("[key_name_admin(src)] froze survival streaks for this round.")
