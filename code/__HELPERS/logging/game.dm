/// Logging for generic/unsorted game messages
/proc/log_game(text)
	if (CONFIG_GET(flag/log_game))
		new /datum/log_entry/game(text)

/// Logging for emotes
/proc/log_emote(text)
	if (CONFIG_GET(flag/log_emote))
		new /datum/log_entry/emote(text)

/// Logging for emotes sent over the radio
/proc/log_radio_emote(text)
	if (CONFIG_GET(flag/log_emote))
		new /datum/log_entry/radio(text)

/// Logging for messages sent in OOC
/proc/log_ooc(text)
	if (CONFIG_GET(flag/log_ooc))
		new /datum/log_entry/ooc(text)

/// Logging for prayed messages
/proc/log_prayer(text)
	if (CONFIG_GET(flag/log_prayer))
		new /datum/log_entry/prayer(text)

/// Logging for changes to ID card access
/proc/log_access(text)
	if (CONFIG_GET(flag/log_access))
		new /datum/log_entry/access(text)

/// Logging for OOC votes
/proc/log_vote(text)
	if (CONFIG_GET(flag/log_vote))
		new /datum/log_entry/vote(text)
