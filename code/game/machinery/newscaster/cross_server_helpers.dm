
/proc/handleIncomingNewscasterRelay(newsdatum_type, newsdatum_json)
	if(!ispath(newsdatum_type))
		newsdatum_type == text2path(newsdatum_type)
	switch(newsdatum_type)
		if(/datum/newscaster/feed_channel)
			handleIncomingNewscasterChannel(newsdatum_json)
		if(/datum/newscaster/feed_message)
			handleIncomingNewscasterMessage(newsdatum_json)
		if(/datum/newscaster/feed_comment)
			handleIncomingNewscasterComment(newsdatum_json)

/proc/handleIncomingNewscasterChannel(json)
	var/datum/newscaster/feed_channel/FC = newschannel_from_json(json)
	if(!istype(FC))
		return FALSE
	var/datum/newscaster/feed_channel/existing = find_news_datum_existing(FC)
	if(istype(existing))
		return FC.merge_to_and_del(existing)
	else
		GLOB.news_network.network_channels += FC
		return TRUE

/proc/handleIncomingNewscasterMessage(json)
	var/datum/newscaster/feed_message/FM = newsmessage_from_json(json)
	if(!istype(FM))
		return FALSE
	var/datum/newscaster/feed_message/existing = find_news_datum_existing(FM)
	if(istype(existing))
		return FM.merge_to_and_del(existing)
	else
		var/datum/newscaster/feed_channel/FC = find_channel_by_md5(FM.channelmd5)
		if(istype(FC))
			FC.messages += FM
			return TRUE
		return FALSE

/proc/handleIncomingNewscasterComment(json)
	var/datum/newscaster/feed_comment/FC = newscomment_from_json(json)
	if(!istype(FC))
		return FALSE
	var/datum/newscaster/feed_comment/existing = find_news_datum_existing(FC)
	if(istype(existing))
		return FC.merge_to_and_del(existing)
	else
		var/datum/newscaaster/feed_message/FM = find_message_by_md5_in_channel(FC.messagemd5, find_channel_by_md5(FC.channelmd5))
		if(istype(FM))
			FM.comments += FC
			return TRUE
		return FALSE

/proc/autoRelayNewscasterDatum(datum/newscaster/D)
	if(!config.cross_allowed)
		return FALSE
	var/list/message = list()
	message["key"] = global.comms_key
	message["source"] = "([config.cross_name])"
	message["crossmessage"] = "Newscaster Relay"
	message["newsdatum_type"] = "[D.type]"
	message["newsdatum_json"] = D.to_json()
	world.Export("[config.cross_address]?[list2params(message)]")

/proc/newscomment_from_json(jsontext)
	var/datum/newscaster/feed_comment/FC = new
	FC.from_json(jsontext)
	return FC

/proc/newsmessage_from_json(jsontext)
	var/datum/newscaster/feed_message/FM = new
	FM.from_json(jsontext)
	return FM

/proc/newschannel_from_json(jsontext)
	var/datum/newscaster/feed_channel/FC = new
	FC.from_json(jsontext)
	return FC

/proc/find_channel_by_md5(md5)
	for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
		if(FC.md5 == md5)
			return FC

/proc/find_message_by_md5_in_channel(md5, datum/newscaster/feed_channel/FC)
	for(var/datum/newscaster/feed_message/FM in FC.messages)
		if(FM.md5 == md5)
			return FM

/proc/find_comment_by_md5_in_message(md5, datum/newscaster/feed_message/FM)
	for(var/datum/newscaster/feed_comment/FC in FM)
		if(FC.md5 == md5)
			return FC

/proc/find_news_datum_existing(datum/newscaster/D)
	if(istype(D, /datum/newscaster/feed_channel))
		return find_channel_by_md5(D.md5)
	if(istype(D, /datum/newscaster/feed_message))
		var/datum/newscaster/feed_message/FM = D
		var/datum/newscaster/feed_channel/FC = find_channel_by_md5(FM.channelmd5)
		if(FC)
			return find_message_by_md5_in_channel(D.md5, FC)
	if(istype(D, /datum/newscaster/feed_comment))
		var/datum/newscaster/feed_comment/FC = D
		var/datum/newscaster/feed_channel/FC1 = find_channel_by_md5(FC.channelmd5)
		if(FC1)
			var/datum/newscaster/feed_message/FM = find_message_by_md5_in_channel(FC.messagemd5, FC1)
			if(FM)
				return find_comment_by_md5_in_message(FC.md5, FM)

/datum/newscaster/proc/to_json()

/datum/newscaster/proc/from_json(jsontext)

/datum/newscaster/feed_comment/generate_md5()
	md5 = md5("[ckey(author)][ckey(body)]")
	return md5

/datum/newscaster/feed_comment/to_json()
	var/list/L = list()
	L["author"] = author
	L["body"] = body
	L["time_stamp"] = time_stamp
	L["md5"] = md5
	L["channelmd5"] = channelmd5
	L["messagemd5"] = messagemd5
	return json_encode(L)

/datum/newscaster/feed_comment/from_json(jsontext)
	var/list/L = json_decode(jsontext)
	if(L["author"])
		author = L["author"]
	if(L["body"])
		body = L["body"]
	if(L["time_stamp"])
		time_stamp = L["time_stamp"]
	if(L["md5"])
		md5 = L["md5"]
	if(L["channelmd5"])
		channelmd5 = L["channelmd5"]
	if(L["messagemd5"])
		messagemd5 = L["messagemd5"]
	return TRUE

/datum/newscaster/feed_message/generate_md5()
	md5 = md5("[ckey(author)][ckey(body)]")
	return md5

/datum/newscaster/feed_message/to_json(include_comments = TRUE, bicon_image = TRUE)
	var/list/L = list()
	L["author"] = author
	L["body"] = body
	L["is_admin_message"] = is_admin_message
	L["time_stamp"] = time_stamp
	L["caption"] = caption
	L["creationTime"] = creationTime
	L["authorCensor"] = authorCensor
	L["channelmd5"] = channelmd5
	L["bodyCensor"] = bodyCensor
	if(include_comments)
		var/list/l = list()
		for(var/v in comments)
			var/datum/newscaster/feed_comment/FC = v
			l += FC.to_json()
		L["comments"] = l
	else
		L["comments"] = list()
	L["locked"] = locked
	L["authorCensorTime"] = authorCensorTime
	L["bodyCensorTime"] = bodyCensorTime
	if(bicon_image)
		L["img"] = icon2base64(img, "CSN_json")
	else
		L["img"] = null
	L["md5"] = md5
	return json_encode(L)

/datum/newscaster/feed_message/from_json(jsontext)
	var/list/L = json_decode(jsontext)
	if(L["author"])
		author = L["author"]
	if(L["body"])
		body = L["body"]
	if(L["md5"])
		md5 = L["md5"]
	if(L["channelmd5"])
		channelmd5 = L["channelmd5"]
	if(L["is_admin_message"])
		is_admin_message = L["is_admin_message"]
	if(L["time_stamp"])
		time_stamp = L["time_stamp"]
	if(L["caption"])
		caption = L["caption"]
	if(L["creationTime"])
		creationTime = L["creationTime"]
	if(L["authorCensor"])
		authorCensor = L["authorCensor"]
	if(L["bodyCensor"])
		bodyCensor = L["bodyCensor"]
	if(L["comments"])
		for(var/v in L["comments"])
			comments += newscomment_from_json(v)
	if(L["locked"])
		locked = L["locked"]
	if(L["authorCensorTime"])
		authorCensorTime = L["authorCensorTime"]
	if(L["bodyCensorTime"])
		bodyCensorTime = L["bodyCensorTime"]
	if(!isnull(L["img"]))
		img = base64toicon(L["img"])
	return TRUE

/datum/newscaster/feed_channel/generate_md5()
	md5 = md5(ckey(channel_name))
	return md5

/datum/newscaster/feed_channel/to_json(include_messages = TRUE, include_comments = TRUE, bicon_pictures = TRUE)
	var/list/L = list()
	L["channel_name"] = channel_name

	if(include_messages)
		var/list/l = list()
		for(var/v in messages)
			var/datum/newscaster/feed_message/FM = v
			l += FM.to_json(include_comments, bicon_pictures)
		L["messages"] = l
	else
		L["messages"] = list()

	L["md5"] = md5
	L["locked"] = locked
	L["censored"] = censored
	L["authorCensorTime"] = authorCensorTime
	L["DclassCensorTime"] = DclassCensorTime
	L["authorCensor"] = authorCensor
	L["is_admin_channel"] = is_admin_channel

	return json_encode(L)

/datum/newscaster/feed_channel/from_json(jsontext)
	var/list/L = json_decode(jsontext)
	if(L["channel_name"])
		channel_name = L["channel_name"]
	if(L["messages"])
		for(var/v in L["messages"])
			messages += newsmessage_from_json(v)
	if(L["locked"])
		locked = L["locked"]
	if(L["censored"])
		censored = L["censored"]
	if(L["md5"])				//ruins the point of it but oh well.
		md5 = L["md5"]
	if(L["authorCensorTime"])
		authorCensorTime = L["authorCensorTime"]
	if(L["DclassCensorTime"])
		DclassCensorTime = L["DclassCensorTime"]
	if(L["authorCensor"])
		authorCensor = L["authorCensor"]
	if(L["is_admin_channel"])
		is_admin_channel = L["is_admin_channel"]

	return TRUE
