/// Logging for generic/unsorted game messages
/proc/log_game(text, list/data)
	logger.Log(LOG_CATEGORY_GAME, text, data)

/// Logging for emotes
/proc/log_emote(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_EMOTE, text, data)

/// Logging for emotes sent over the radio
/proc/log_radio_emote(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_RADIO_EMOTE, text, data)

/// Logging for messages sent in OOC
/proc/log_ooc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_OOC, text, data)

/// Logging for prayed messages
/proc/log_prayer(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_PRAYER, text, data)

/// Logging for music requests
/proc/log_internet_request(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_INTERNET_REQUEST, text, data)

/// Logging for logging in & out of the game, with error messages.
/proc/log_access(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_ACCESS, text, data)

/// Logging for OOC votes
/proc/log_vote(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_VOTE, text, data)

/proc/log_ghost_poll(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_GHOST_POLLS, text, data)
