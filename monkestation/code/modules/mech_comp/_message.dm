
///When we have our ghetto computer 3, this will be more useful.
/datum/mcmessage
	var/cmd = MC_BOOL_TRUE
	var/list/senders = list()

/datum/mcmessage/New(_cmd)
	cmd = _cmd

/datum/mcmessage/proc/Copy()
	var/datum/mcmessage/newmsg = new(cmd)
	newmsg.senders = senders.Copy()
	return newmsg

/datum/mcmessage/proc/Truthy()
	return ((lowertext(cmd) == MC_BOOL_TRUE) || (cmd == "1"))

/datum/mcmessage/proc/AddSender(datum/mcinterface/I)
	senders += I

/datum/mcmessage/proc/CheckSender(datum/mcinterface/I)
	return (I in senders)
