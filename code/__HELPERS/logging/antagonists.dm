/// Logging for traitor objectives
/proc/log_traitor(text)
	GLOB.logger.Log(LOG_CATEGORY_GAME_TRAITOR, text)

/// Logging for items purchased from a traitor uplink
/proc/log_uplink(text)
	GLOB.logger.Log(LOG_CATEGORY_UPLINK, text)

/// Logging for upgrades purchased by a malfunctioning (or combat upgraded) AI
/proc/log_malf_upgrades(text)
	GLOB.logger.Log(LOG_CATEGORY_UPLINK_MALF, text)

/// Logging for changeling powers purchased
/proc/log_changeling_power(text)
	GLOB.logger.Log(LOG_CATEGORY_UPLINK_CHANGELING, text)

/// Logging for heretic powers learned
/proc/log_heretic_knowledge(text)
	GLOB.logger.Log(LOG_CATEGORY_UPLINK_HERETIC, text)

/// Logging for wizard powers learned
/proc/log_spellbook(text)
	GLOB.logger.Log(LOG_CATEGORY_UPLINK_SPELL, text)
