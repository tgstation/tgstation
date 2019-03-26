


/datum/controller/subsystem/ticker/proc/ResetExtendedMode() // FULPSTATION: Reset to "secret" if left on "secret extended" or "extended". Called from fire() in ticker.dm
	if (GLOB.master_mode == "secret_extended" || GLOB.master_mode == "extended")
		message_admins("Game mode was left on '[GLOB.master_mode]' after startup. Resetting to 'secret'. It is now safe to reselect '[GLOB.master_mode]' for this round." )
		GLOB.master_mode = "secret"
		save_mode(GLOB.master_mode) // Normally SSticker.save_mode(), but we're already in here.
	// TO IMPLEMENT: add ResetExtendedMode() to line 144, after "current_state = GAME_STATE_PREGAME"
	// WHY ITS NOT DONE: GitHub keeps beliving a tab is being deleted or something, any time ANY change is made to ticker.dm, so let's just wait.
