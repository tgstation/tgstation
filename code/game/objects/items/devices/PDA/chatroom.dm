var/list/chatrooms = list()

/datum/chatroom
	var/name = "Generic Chatroom"
	var/list/logged_in = list()
	var/list/logs = list() // chat logs
	var/list/banned = list() // banned users
	var/list/whitelist = list() // whitelisted users
	var/list/muted = list()
	var/topic = "" // topic message for the chatroom
	var/password = "" // blank for no password.
	var/operator = "" // name of the operator

/datum/chatroom/proc/attempt_connect(var/obj/item/device/pda/device, var/obj/password)
	if(!device)
		return
