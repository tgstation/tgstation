/// This logs subtle emotes in game.log
/proc/log_subtle(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_SUBTLE, text, data)
