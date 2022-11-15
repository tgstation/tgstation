#define MAX_CHANNELS 1000

/datum/ntnet_conversation
	///The title of the conversation, seen in the UI.
	var/title = "Untitled Conversation"
	//If a channel is strong, it cannot be renamed or deleted.
	var/strong = FALSE
	///The password to join a channel, set by an Administrator.
	var/password

	///A static UID to ensure no conversations are the same.
	var/static/ntnrc_uid = 0
	///ID using the UID.
	var/id

	///List of all messages sent in the conversation.
	var/list/messages = list()

	///The "Administrator" of the channel, the creator starts as channel's operator by default.
	var/datum/computer_file/program/chatclient/channel_operator
	///Chat clients who are active or minimized.
	var/list/datum/computer_file/program/chatclient/active_clients = list()
	///Chat clients who have exited out of the program.
	var/list/datum/computer_file/program/chatclient/offline_clients = list()
	///Chat clients currently muted by the operator, rendering them unable to ping other people.
	var/list/datum/computer_file/program/chatclient/muted_clients = list()

/datum/ntnet_conversation/New(title, strong = FALSE)
	src.title = title
	src.strong = strong

	id = ntnrc_uid
	ntnrc_uid++
	if(id > MAX_CHANNELS)
		qdel(src)
		return
	if(SSnetworks.station_network)
		SSnetworks.station_network.chat_channels.Add(src)
	return ..()

/datum/ntnet_conversation/Destroy()
	if(SSnetworks.station_network)
		SSnetworks.station_network.chat_channels.Remove(src)
	for(var/datum/computer_file/program/chatclient/chatterbox as anything in (active_clients | offline_clients))
		purge_client(chatterbox)
	return ..()

/datum/ntnet_conversation/proc/add_message(message, username)
	message = "[station_time_timestamp(format = "hh:mm")] [username]: [message]"
	messages.Add(message)
	trim_message_list()

/datum/ntnet_conversation/proc/add_status_message(message)
	messages.Add("[station_time_timestamp(format = "hh:mm")] -!- [message]")
	trim_message_list()

/datum/ntnet_conversation/proc/trim_message_list()
	if(messages.len <= 50)
		return
	messages = messages.Copy(messages.len-50 ,0)

/datum/ntnet_conversation/proc/add_client(datum/computer_file/program/chatclient/new_user, silent = FALSE)
	if(!istype(new_user))
		return
	new_user.conversations |= src
	active_clients.Add(new_user)
	if(!silent)
		add_status_message("[new_user.username] has joined the channel.")
	// No operator, so we assume the channel was empty. Assign this user as operator, without the message, since you're the creator.
	if(!channel_operator)
		changeop(new_user, silent = TRUE)

//Clear all of our references to a client, used for client deletion
/datum/ntnet_conversation/proc/purge_client(datum/computer_file/program/chatclient/forget)
	remove_client(forget)
	forget.conversations -= src

/datum/ntnet_conversation/proc/remove_client(datum/computer_file/program/chatclient/leaving)
	if(!istype(leaving))
		return
	if(leaving in active_clients)
		active_clients.Remove(leaving)
		add_status_message("[leaving.username] has left the channel.")
	muted_clients -= leaving
	offline_clients -= leaving

	// Channel operator left, pick new operator
	if(leaving == channel_operator)
		channel_operator = null
		if(active_clients.len)
			var/datum/computer_file/program/chatclient/newop = pick(active_clients)
			changeop(newop)

/datum/ntnet_conversation/proc/go_offline(datum/computer_file/program/chatclient/offline)
	if(!istype(offline) || !(offline in active_clients))
		return
	active_clients.Remove(offline)
	offline_clients.Add(offline)

/datum/ntnet_conversation/proc/mute_user(datum/computer_file/program/chatclient/op, datum/computer_file/program/chatclient/muted)
	if(!op.netadmin_mode && (channel_operator != op)) //sanity even if the person shouldn't be able to see the mute button
		return
	if(muted in muted_clients)
		muted_clients.Remove(muted)
		muted.computer.alert_call(muted, "You have been unmuted from [title]!", 'sound/machines/ping.ogg')
	else
		muted_clients.Add(muted)
		muted.computer.alert_call(muted, "You have been muted from [title]!")

/datum/ntnet_conversation/proc/ping_user(datum/computer_file/program/chatclient/pinger, datum/computer_file/program/chatclient/pinged)
	if(pinger in muted_clients) //oh my god fuck off
		return
	add_status_message("[pinger.username] pinged [pinged.username].")
	pinged.computer.alert_call(pinged, "You have been pinged in [title] by [pinger.username]!", 'sound/machines/ping.ogg')

/datum/ntnet_conversation/proc/changeop(datum/computer_file/program/chatclient/newop, silent = FALSE)
	if(!istype(newop))
		CRASH("[src] is attempting to add [newop] as the operator, but it isn't a chat client.")
	channel_operator = newop
	if(!silent)
		add_status_message("Channel operator status transferred to [newop.username].")

/datum/ntnet_conversation/proc/change_title(newtitle, datum/computer_file/program/chatclient/renamer)
	if((channel_operator != renamer) || strong) // Not Authorised or channel cannot be editted
		return FALSE
	add_status_message("[renamer.username] has changed channel title from [title] to [newtitle]")
	title = newtitle

#undef MAX_CHANNELS
