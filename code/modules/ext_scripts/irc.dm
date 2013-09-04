/proc/send2irc(var/channel, var/msg)
	if(config.use_irc_bot && config.irc_bot_host)
		ext_python("ircbot_message.py", "[config.comms_password] [config.irc_bot_host] [channel] [msg]")
	return

/proc/send2mainirc(var/msg)
	if(config.use_irc_bot && config.main_irc && config.irc_bot_host)
		ext_python("ircbot_message.py", "[config.comms_password] [config.irc_bot_host] [config.main_irc] [msg]")
	return

/proc/send2adminirc(var/msg)
	if(config.use_irc_bot && config.admin_irc && config.irc_bot_host)
		ext_python("ircbot_message.py", "[config.comms_password] [config.irc_bot_host] [config.admin_irc] [msg]")
	return
