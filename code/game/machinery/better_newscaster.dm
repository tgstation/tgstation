/obj/item/newser
	name = "newser"
	desc = "I'm going to delete this anyway, if it still exists Arcane fucked up!"
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"
	///What newscaster channel is currently being viewed by the player?
	var/datum/newscaster/feed_channel/current_channel

/obj/item/newser/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Newscaster", name)
		ui.open()

/obj/item/newser/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/channel_list = list()
	var/list/message_list = list()

	//Code assigning name and Job Information, taken from the player mob's ID card if one exists.
	var/obj/item/card/id/C
	if(isliving(user))
		var/mob/living/L = user
		C = L.get_idcard(TRUE)
	if(C?.registered_account)
		data["user"] = list()
		data["user"]["name"] = C.registered_account.account_holder
		data["user"]["cash"] = C.registered_account.account_balance
		if(C.registered_account.account_job)
			data["user"]["job"] = C.registered_account.account_job.title
			data["user"]["department"] = C.registered_account.account_job.paycheck_department
		else
			data["user"]["job"] = "No Job"
			data["user"]["department"] = "No Department"

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	for(var/datum/newscaster/feed_channel/channel in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"auth" = channel.author,
			"desc" = channel.channel_desc,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
			))
		for(var/datum/newscaster/feed_message/comment_message in channel.messages)
			message_list += list(list(
			"auth" = comment_message.author,
			"body" = comment_message.body,
			"channel_num" = comment_message.parent_ID,
			))
	data["viewing_channel"] = current_channel.channel_ID
	data["channel"] = channel_list
	data["messages"] = message_list

	return data

/obj/item/newser/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("setChannel")
			if(isnull(params["channels"]))
				return
			var/proto_chan = text2path(params["channels"])
			if(!(proto_chan in GLOB.news_network.network_channels))
				return
			current_channel = params["category"]
			//say(current_channel)
			. = TRUE
