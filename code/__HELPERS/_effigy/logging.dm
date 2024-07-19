#define PREF "PREF"

/proc/effigy_debug(message, type)
	var/msg_type = type
	if(isnull(type))
		msg_type = "GAME"
	to_chat(world, span_debugcyan("\[EF]\[[span_debugyellow(msg_type)]\] [message]"))
