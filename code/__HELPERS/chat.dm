/*

Here's how to use the chat system with configs

send2adminchat is a simple function that broadcasts to admin channels

send2chat is a bit verbose but can be very specific

The second parameter is a string, this string should be read from a config.
What this does is dictacte which TGS4 channels can be sent to.

For example if you have the following channels in tgs4 set up
- Channel 1, Tag: asdf
- Channel 2, Tag: bombay,asdf
- Channel 3, Tag: Hello my name is asdf
- Channel 4, No Tag
- Channel 5, Tag: butts

and you make the call:

send2chat("I sniff butts", CONFIG_GET(string/where_to_send_sniff_butts))

and the config option is set like:

WHERE_TO_SEND_SNIFF_BUTTS asdf

It will be sent to channels 1 and 2

Alternatively if you set the config option to just:

WHERE_TO_SEND_SNIFF_BUTTS

it will be sent to all connected chats.

In TGS3 it will always be sent to all connected designated game chats.
*/

/**
  * Sends a message to TGS chat channels.
  *
  * message - The message to send.
  * channel_tag - Required. If "", the message with be sent to all connected (Game-type for TGS3) channels. Otherwise, it will be sent to TGS4 channels with that tag (Delimited by ','s).
  */
/proc/send2chat(message, channel_tag)
	if(channel_tag == null || !world.TgsAvailable())
		return

	var/datum/tgs_version/version = world.TgsVersion()
	if(channel_tag == "" || version.suite == 3)
		world.TgsTargetedChatBroadcast(message, FALSE)
		return

	var/list/channels_to_use = list()
	for(var/I in world.TgsChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I
		var/list/applicable_tags = splittext(channel.custom_tag, ",")
		if(channel_tag in applicable_tags)
			channels_to_use += channel

	if(channels_to_use.len)
		world.TgsChatBroadcast(message, channels_to_use)

/**
  * Sends a message to TGS admin chat channels.
  *
  * category - The category of the mssage.
  * message - The message to send.
  */
/proc/send2adminchat(category, message)
	category = replacetext(replacetext(category, "\proper", ""), "\improper", "")
	message = replacetext(replacetext(message, "\proper", ""), "\improper", "")
	world.TgsTargetedChatBroadcast("[category] | [message]", TRUE)
