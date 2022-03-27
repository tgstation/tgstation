///SSrunechat, essentially acts as a hyper specialized SStimer that only works for [/datum/chatmessage] instances to schedule events in the future
///without the overhead of more general timing systems.
TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT

	///list that keeps track of all runechat message datums by their creation_string. used to keep track of runechat messages.
	///associative list of the form: list(creation string = the chatmessage datum assigned to that string)
	var/list/messages_by_creation_string = list()
