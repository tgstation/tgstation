TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT
	///list that keeps track of all runechat message datums assigned to a speaker.
	///associative list of the form: list(speaker = list(all [/datum/chatmessage] instances assigned to that speaker))
	var/list/messages_by_speaker = list()
