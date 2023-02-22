/// Logging for generic/unsorted game messages
/proc/log_game(text)
	Logger.Log(LOG_CATEGORY_GAME, text)

/// Logging for emotes
/proc/log_emote(text)
	Logger.Log(LOG_CATEGORY_GAME_EMOTE, text)

/// Logging for emotes sent over the radio
/proc/log_radio_emote(text)
	Logger.Log(LOG_CATEGORY_GAME_RADIO_EMOTE, text)

/// Logging for messages sent in OOC
/proc/log_ooc(text)
	Logger.Log(LOG_CATEGORY_GAME_OOC, text)

/// Logging for prayed messages
/proc/log_prayer(text)
	Logger.Log(LOG_CATEGORY_GAME_PRAYER, text)

/// Logging for changes to ID card access
/proc/log_access(text)
	Logger.Log(LOG_CATEGORY_GAME_ACCESS, text)

/// Logging for OOC votes
/proc/log_vote(text)
	Logger.Log(LOG_CATEGORY_GAME_VOTE, text)

