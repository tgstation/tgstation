GLOBAL_LIST_EMPTY(clientmessages)

/proc/addclientmessage(var/ckey, var/message)
	ckey = ckey(ckey)
	if (!ckey || !message)
		return
	if (!(ckey in GLOB.clientmessages))
		GLOB.clientmessages[ckey] = list()
	GLOB.clientmessages[ckey] += message