var/list/clientmessages = list()

/proc/addclientmessage(var/ckey, var/message)
	ckey = ckey(ckey)
	if (!ckey || !message)
		return
	if (!(ckey in clientmessages))
		clientmessages[ckey] = list()
	clientmessages[ckey] += message