/obj/item/newser
	name = "newser"
	desc = "I'm going to delete this anyway, if it still exists Arcane fucked up!"
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"
	///What newscaster channel is currently being viewed by the player?
	var/datum/newscaster/feed_channel/current_channel
	///The message that's currently being written for a feed story.
	var/feed_channel_message
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Value of the currently bounty input
	var/bounty_value = 1
	///Text of the currently written bounty
	var/bounty_text = ""

/obj/item/newser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Newscaster", name)
		ui.open()

/obj/item/newser/ui_data(mob/user)
	. = ..()
	//**************************
	//		Newscaster Data
	//**************************
	var/list/data = list()
	var/list/channel_list = list()
	var/list/message_list = list()

	//Code displaying name and Job Information, taken from the player mob's ID card if one exists.
	var/obj/item/card/id/Card
	if(isliving(user))
		var/mob/living/L = user
		Card = L.get_idcard(TRUE)
	if(Card?.registered_account)
		current_user = Card.registered_account
		data["user"] = list()
		data["user"]["name"] = Card.registered_account.account_holder
		data["user"]["cash"] = Card.registered_account.account_balance
		if(Card.registered_account.account_job)
			data["user"]["job"] = Card.registered_account.account_job.title
			data["user"]["department"] = Card.registered_account.account_job.paycheck_department
		else
			data["user"]["job"] = "No Job"
			data["user"]["department"] = "No Department"

	data["security_mode"] = FALSE
	if(Card && (ACCESS_ARMORY in Card?.GetAccess()))
		data["security_mode"] = TRUE

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	for(var/datum/newscaster/feed_channel/channel in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
			))
		for(var/datum/newscaster/feed_message/comment_message in channel.messages)
			message_list += list(list(
			"auth" = comment_message.author,
			"body" = comment_message.body,
			"time" = comment_message.time_stamp,
			"channel_num" = comment_message.parent_ID,
			))
	data["viewing_channel"] = current_channel?.channel_ID

	//Here we display all the information about the current channel.
	data["channelName"] = current_channel?.channel_name
	data["channelAuthor"] = current_channel?.author
	data["channelDesc"] = current_channel?.channel_desc
	data["channelBlocked"] = current_channel?.locked || current_channel?.censored

	//We send all the information about all channels and all messages in existance.
	data["channel"] = channel_list
	data["messages"] = message_list

	//**************************
	//	  Bounty Board Data
	//**************************
	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	for(var/i in GLOB.request_list)
		if(!i)
			continue
		var/datum/station_request/request = i
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/j in request.applicants)
				formatted_applicants += list(list("name" = j.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = j.account_id))
	if(Card?.registered_account) //work out current user.
		data["accountName"] = Card.registered_account.account_holder
	data["requests"] = formatted_requests
	data["applicants"] = formatted_applicants
	data["bountyValue"] = bounty_value
	data["bountyText"] = bounty_text

	return data

/obj/item/newser/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("setChannel")
			if(isnull(params["channels"]))
				return
			var/proto_chan = (params["channels"])
			for(var/datum/newscaster/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(proto_chan == potential_channel.channel_ID)
					current_channel = potential_channel
			say("[current_channel.channel_name] has been set yaknow what i'm saying")
			. = TRUE

		if("createStory")
			var/proto_chan = (params["current"])
			for(var/datum/newscaster/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(proto_chan == potential_channel.channel_ID)
					current_channel = potential_channel
			var/temp_message = tgui_input_text(usr, "Write your Feed story", "Network Channel Handler", feed_channel_message, multiline = TRUE)
			if(temp_message)
				feed_channel_message = temp_message
			GLOB.news_network.SubmitArticle("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, usr)]</font>", current_user.account_holder, current_channel.channel_name, null, 0, FALSE)
			SSblackbox.record_feedback("amount", "newscaster_stories", 1)
			feed_channel_message = ""

		if("storyCensor")
			if (!params["secure"])
				return
			say("This is where I'd censor the story if I could.")
			. = TRUE

		if("authorCensor")
			if (!params["secure"])
				return
			say("This is where I'd censor the author if I could.")
			. = TRUE
