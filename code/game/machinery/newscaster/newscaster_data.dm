GLOBAL_DATUM_INIT(news_network, /datum/feed_network, new)
GLOBAL_LIST_EMPTY(allCasters)

GLOBAL_LIST_EMPTY(allbountyboards)
GLOBAL_LIST_EMPTY(request_list)

/datum/feed_comment
	///The author of the comment, as seen on a newscaster feed.
	var/author = ""
	///Body of the aforementioned comment.
	var/body = ""
	///At what time was the feed comment sent? Time is in station time.
	var/time_stamp = ""

/datum/feed_message
	///Who is the author of the full-size article to the feed channel?
	var/author =""
	///Body of the full-size article to the feed channel.
	var/body =""
	///In station time, at what time was the author's messages censored and blocked from viewing.
	var/list/author_censor_time = list()
	///In station time, at what time was this message censored and blocked from viewing.
	var/list/body_censor_time = list()
	///Did an admin send this message?
	var/is_admin_message = FALSE
	///Is there an image tied to the feed message?
	var/icon/img = null
	///At what time was the full-size article sent? Time is in station time.
	var/time_stamp = ""
	///List consisting of the articles feed comments for this full-size article.
	var/list/datum/feed_comment/comments = list()
	///Can comments be placed on that feed message?
	var/locked = FALSE
	///If the message has an image, what is that image's caption?
	var/caption = ""
	///At what time was the feed message created?
	var/creation_time
	///Has the author been blocked from making new feed messages?
	var/author_censor
	///Has the body of the message been censored?
	var/body_censor
	///Referece to the photo used in picture messages.
	var/photo_file
	///What is the channel ID of the parent channel?
	var/parent_ID
	///What number message is this? IE: The first message sent in a round including automated messages is message 1.
	var/message_ID

/datum/feed_message/proc/return_author(censor)
	if(censor == -1)
		censor = author_censor
	var/txt = "[GLOB.news_network.redacted_text]"
	if(!censor)
		txt = author
	return txt

/datum/feed_message/proc/return_body(censor)
	if(censor == -1)
		censor = body_censor
	var/txt = "[GLOB.news_network.redacted_text]"
	if(!censor)
		txt = body
	return txt

/datum/feed_message/proc/toggle_censor_author()
	if(author_censor)
		author_censor_time.Add(GLOB.news_network.last_action*-1)
	else
		author_censor_time.Add(GLOB.news_network.last_action)
	author_censor = !author_censor
	GLOB.news_network.last_action ++

/datum/feed_message/proc/toggle_censor_body()
	if(body_censor)
		body_censor_time.Add(GLOB.news_network.last_action*-1)
	else
		body_censor_time.Add(GLOB.news_network.last_action)
	body_censor = !body_censor
	GLOB.news_network.last_action ++

/datum/feed_channel
	/// The name of the channel, players see this on the channel selection list
	var/channel_name = ""
	/// The description of the channel, players see this upon clicking on the channel before seeing messages.
	var/channel_desc = ""
	/// Datum list of all feed_messages.
	var/list/datum/feed_message/messages = list()
	/// Is the channel locked? Locked channels cannot be commented on.
	var/locked = FALSE
	/// Who is the author of this channel? Taken from the user's ID card.
	var/author = ""
	/// Has this channel been censored? Where Locked channels cannot be commented on, Censored channels cannot be viewed at all.
	var/censored = FALSE
	/// At what times has the author been censored?
	var/list/author_censor_time = list()
	/// At what times has the author been D-Class censored.
	var/list/D_class_censor_time = list()
	/// Has the author of the channel been censored, as opposed to the message itself?
	var/author_censor
	/// Is this an admin channel? Allows for actions to be taken by the admin only.
	var/is_admin_channel = FALSE
	/// Channel ID is a random number sequence similar to account ID number that allows for us to link messages to the proper channels through the UI backend.
	var/channel_ID

/datum/feed_channel/New()
	. = ..()
	channel_ID = random_channel_id_setup()

/**
 * This proc assigns each feed_channel a random integer, from 1-999 as a unique identifier.
 * Using this value, the TGUI window has a unique identifier to attach to messages that can be used to reattach them
 * to their parent channels back in dreammaker.
 * Based on implementation, we're limiting ourselves to only 998 player made channels maximum. How we'd use all of them, I don't know.
 */
/datum/feed_channel/proc/random_channel_id_setup()
	if(!GLOB.news_network)
		return //Should only apply to channels made before setup is finished, use hardset_channel for these
	if(!GLOB.news_network.channel_IDs)
		GLOB.news_network.channel_IDs += rand(1,999)
		return //This will almost always be the station announcements channel here.
	var/channel_id
	for(var/i in 1 to 10000)
		channel_id = rand(1, 999)
		if(!GLOB.news_network.channel_IDs["[channel_ID]"])
			break
	channel_ID = channel_id
	return channel_ID

/datum/feed_channel/proc/return_author(censor)
	if(censor == -1)
		censor = author_censor
	var/txt = "[GLOB.news_network.redacted_text]"
	if(!censor)
		txt = author
	return txt

/datum/feed_channel/proc/toggle_censor_D_class()
	if(censored)
		D_class_censor_time.Add(GLOB.news_network.last_action*-1)
	else
		D_class_censor_time.Add(GLOB.news_network.last_action)
	censored = !censored
	GLOB.news_network.last_action ++

/datum/feed_channel/proc/toggle_censor_author()
	if(author_censor)
		author_censor_time.Add(GLOB.news_network.last_action*-1)
	else
		author_censor_time.Add(GLOB.news_network.last_action)
	author_censor = !author_censor
	GLOB.news_network.last_action ++

/datum/wanted_message
	/// Is this criminal alert still active?
	var/active
	/// What is the criminal in question's name? Not a mob reference as this is a text field.
	var/criminal
	/// Message body used to describe what crime has been committed.
	var/body
	/// Who was it that created this wanted message?
	var/scanned_user
	/// Is this an admin message? Prevents editing unless performed by an admin rank.
	var/is_admin_msg
	/// Icon image to be attached to the newscaster message.
	var/icon/img
	/// Reference to the photo file used by wanted message on creation.
	var/photo_file

/datum/feed_network
	/// All the feed channels that have been made on the feed network.
	var/list/datum/feed_channel/network_channels = list()
	/// What is the wanted issue being sent out to all newscasters.
	var/datum/wanted_message/wanted_issue
	/// What time was the last action taken on the feed_network?
	var/last_action
	/// What does this feed network say when a message/author is redacted?
	var/redacted_text = "\[REDACTED\]"
	/// List of all the network_channels Channel Id numbers, kept in a global easy to find place.
	var/list/channel_IDs = list()
	/// How many messages currently exist on this feed_network? Increments as new messages are written.
	var/message_count = 0

/datum/feed_network/New()
	create_feed_channel("Station Announcements", "SS13", "Company news, staff announcements, and all the latest information. Have a secure shift!", locked = TRUE, hardset_channel = 1000)
	wanted_issue = new /datum/wanted_message

/datum/feed_network/proc/create_feed_channel(channel_name, author, desc, locked, adminChannel = FALSE, hardset_channel)
	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = channel_name
	newChannel.author = author
	newChannel.channel_desc = desc
	newChannel.locked = locked
	newChannel.is_admin_channel = adminChannel
	if(hardset_channel)
		newChannel.channel_ID = hardset_channel
	network_channels += newChannel

/datum/feed_network/proc/submit_article(msg, author, channel_name, datum/picture/picture, adminMessage = FALSE, allow_comments = TRUE, update_alert = TRUE)
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = author
	newMsg.body = msg
	newMsg.time_stamp = "[station_time_timestamp()]"
	newMsg.is_admin_message = adminMessage
	newMsg.locked = !allow_comments
	if(picture)
		newMsg.img = picture.picture_image
		newMsg.caption = picture.caption
		newMsg.photo_file = save_photo(picture.picture_image)
	for(var/datum/feed_channel/FC in network_channels)
		if(FC.channel_name == channel_name)
			FC.messages += newMsg
			newMsg.parent_ID = FC.channel_ID
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.news_alert(channel_name, update_alert)
	last_action ++
	newMsg.creation_time = last_action
	message_count ++
	newMsg.message_ID = message_count

/datum/feed_network/proc/submit_wanted(criminal, body, scanned_user, datum/picture/picture, adminMsg = FALSE, newMessage = FALSE)
	wanted_issue.active = TRUE
	wanted_issue.criminal = criminal
	wanted_issue.body = body
	wanted_issue.scanned_user = scanned_user
	wanted_issue.is_admin_msg = adminMsg
	if(picture)
		wanted_issue.img = picture.picture_image
		wanted_issue.photo_file = save_photo(picture.picture_image)
	if(newMessage)
		for(var/obj/machinery/newscaster/N in GLOB.allCasters)
			N.news_alert()
			N.update_appearance()

/datum/feed_network/proc/delete_wanted()
	wanted_issue.active = FALSE
	wanted_issue.criminal = null
	wanted_issue.body = null
	wanted_issue.scanned_user = null
	wanted_issue.img = null
	for(var/obj/machinery/newscaster/updated_newscaster in GLOB.allCasters)
		updated_newscaster.update_appearance()

/datum/feed_network/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("\icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

//**************************
//	 Bounty Board Datums
//**************************


/**
 * A combined all in one datum that stores everything about the request, the requester's account, as well as the requestee's account
 * All of this is passed to the Request Console UI in order to present in organized way.
 */
/datum/station_request
	///Name of the Request Owner.
	var/owner
	///Value of the request.
	var/value
	///Text description of the request to be shown within the UI.
	var/description
	///Internal number of the request for organizing. Id card number.
	var/req_number
	///The account of the request owner.
	var/datum/bank_account/owner_account
	///the account of the request fulfiller.
	var/list/applicants = list()

/datum/station_request/New(owned, newvalue, newdescription, reqnum, own_account)
	. = ..()
	owner = owned
	value = newvalue
	description = newdescription
	req_number = reqnum
	if(istype(own_account, /datum/bank_account))
		owner_account = own_account
