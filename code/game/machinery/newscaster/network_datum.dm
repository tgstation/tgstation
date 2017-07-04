GLOBAL_DATUM_INIT(news_network, /datum/newscaster/feed_network, new)
GLOBAL_LIST_EMPTY(allCasters)

/datum/newscaster
	var/md5 = ""

/datum/newscaster/proc/generate_md5()

/datum/newscaster/proc/merge_to_and_del(datum/newscaster/D)
	if(D.type != type)
		return FALSE
	qdel(src)
	return TRUE

/datum/newscaster/feed_comment
	var/author = ""
	var/body = ""
	var/time_stamp = ""
	var/channelmd5 = ""
	var/messagemd5 = ""

/datum/newscaster/feed_message
	var/author = ""
	var/body = ""
	var/channelmd5 = ""
	var/list/authorCensorTime = list()
	var/list/bodyCensorTime = list()
	var/is_admin_message = 0
	var/icon/img = null
	var/time_stamp = ""
	var/list/datum/newscaster/feed_comment/comments = list()
	var/locked = 0
	var/caption = ""
	var/creationTime
	var/authorCensor
	var/bodyCensor

/datum/newscaster/feed_message/Destroy()
	QDEL_LIST(comments)
	return ..()

/datum/newscaster/feed_message/proc/merge_to_and_del(datum/newscaster/D)
	if(D.type != type)
		return FALSE
	D.comments |= comments
	qdel(src)

/datum/newscaster/feed_message/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_message/proc/returnBody(censor)
	if(censor == -1)
		censor = bodyCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = body
	return txt

/datum/newscaster/feed_message/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_message/proc/toggleCensorBody()
	if(bodyCensor)
		bodyCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		bodyCensorTime.Add(GLOB.news_network.lastAction)
	bodyCensor = !bodyCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel
	var/channel_name = ""
	var/list/datum/newscaster/feed_message/messages = list()
	var/locked = 0
	var/author = ""
	var/censored = 0
	var/list/authorCensorTime = list()
	var/list/DclassCensorTime = list()
	var/authorCensor
	var/is_admin_channel = 0

/datum/newscaster/feed_channel/Destroy()
	QDEL_LIST(messages)
	return ..()

/datum/newscaster/feed_channel/merge_to_and_del(datum/newscaster/D)
	if(D.type != type)
		return FALSE
	D.messages |= messages
	qdel(src)
	return TRUE

/datum/newscaster/feed_channel/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_channel/proc/toggleCensorDclass()
	if(censored)
		DclassCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		DclassCensorTime.Add(GLOB.news_network.lastAction)
	censored = !censored
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/wanted_message
	var/active
	var/criminal
	var/body
	var/scannedUser
	var/isAdminMsg
	var/icon/img

/datum/newscaster/feed_network
	var/list/datum/newscaster/feed_channel/network_channels = list()
	var/datum/newscaster/wanted_message/wanted_issue
	var/lastAction
	var/redactedText = "\[REDACTED\]"

/datum/newscaster/feed_network/New()
	CreateFeedChannel("Station Announcements", "SS13", 1)
	wanted_issue = new /datum/newscaster/wanted_message

/datum/newscaster/feed_network/proc/CreateFeedChannel(channel_name, author, locked, adminChannel = 0)
	var/datum/newscaster/feed_channel/newChannel = new /datum/newscaster/feed_channel
	newChannel.channel_name = channel_name
	newChannel.author = author
	newChannel.locked = locked
	newChannel.is_admin_channel = adminChannel
	newChannel.generate_md5()
	network_channels += newChannel

/datum/newscaster/feed_network/proc/SubmitArticle(msg, author, channel_name, obj/item/weapon/photo/photo, adminMessage = 0, allow_comments = 1)
	var/datum/newscaster/feed_message/newMsg = new /datum/newscaster/feed_message
	newMsg.author = author
	newMsg.body = msg
	newMsg.time_stamp = "[worldtime2text()]"
	newMsg.is_admin_message = adminMessage
	newMsg.locked = !allow_comments
	newMsg.generate_md5()
	if(photo)
		newMsg.img = photo.img
		newMsg.caption = photo.scribble
	for(var/datum/newscaster/feed_channel/FC in network_channels)
		if(FC.channel_name == channel_name)
			FC.messages += newMsg
			newMsg.channelmd5 = FC.md5
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.newsAlert(channel_name)
	lastAction ++
	newMsg.creationTime = lastAction

/datum/newscaster/feed_network/proc/submitWanted(criminal, body, scanned_user, obj/item/weapon/photo/photo, adminMsg = 0, newMessage = 0)
	wanted_issue.active = 1
	wanted_issue.criminal = criminal
	wanted_issue.body = body
	wanted_issue.scannedUser = scanned_user
	wanted_issue.isAdminMsg = adminMsg
	if(photo)
		wanted_issue.img = photo.img
	if(newMessage)
		for(var/obj/machinery/newscaster/N in GLOB.allCasters)
			N.newsAlert()
			N.update_icon()

/datum/newscaster/feed_network/proc/deleteWanted()
	wanted_issue.active = 0
	wanted_issue.criminal = null
	wanted_issue.body = null
	wanted_issue.scannedUser = null
	wanted_issue.img = null
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.update_icon()

