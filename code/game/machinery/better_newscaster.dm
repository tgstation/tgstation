/obj/item/newser
	name = "newser"
	desc = "I'm going to delete this anyway, if it still exists Arcane fucked up!"
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"

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
	for(var/datum/newscaster/feed_network/channel in GLOB.news_network.network_channels)
		channel_list += list(list(
				var/list/messages = list()
				"name" = channel.name,
				"auth" = channel.author,
				if(channel.messages)
					for(var/comment_message in channel.messages)
					message_list += list(list(
					"auth" += comment_message.author
					"body" += comment_message.body
					))
			))
	data["newscaster"] = channel_list


	return data
