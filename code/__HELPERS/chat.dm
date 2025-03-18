/*

Here's how to use the TGS chat system with configs

send2adminchat is a simple function that broadcasts to all admin channels that are designated in TGS

send2chat is a bit verbose but can be very specific

In TGS3 it will always be sent to all connected designated game chats.

In TGS4+ they use the new tagging system

The second parameter is a string, this string should be read from a config.
What this does is dictate which TGS channels can be sent to.

For example if you have the following channels in tgs4 set up
- Channel 1, Tag: asdf
- Channel 2, Tag: bombay,asdf
- Channel 3, Tag: Hello my name is asdf
- Channel 4, No Tag
- Channel 5, Tag: butts

and you make the call:

send2chat(new /datum/tgs_message_content("I sniff butts"), CONFIG_GET(string/where_to_send_sniff_butts))

and the config option is set like:

WHERE_TO_SEND_SNIFF_BUTTS asdf

It will be sent to channels 1 and 2

Alternatively if you set the config option to just:

WHERE_TO_SEND_SNIFF_BUTTS

it will be sent to all connected chats.
*/

/**
 * Asynchronously sends a message to TGS chat channels.
 *
 * message - The [/datum/tgs_message_content] to send.
 * channel_tag - Required. If "", the message with be sent to all connected (Game-type for TGS3) channels. Otherwise, it will be sent to TGS4 channels with that tag (Delimited by ','s).
 * admin_only - Determines if this communication can only be sent to admin only channels.
 */
/proc/send2chat(datum/tgs_message_content/message, channel_tag, admin_only = FALSE)
	set waitfor = FALSE
	if(channel_tag == null || !world.TgsAvailable())
		return

	var/datum/tgs_version/version = world.TgsVersion()
	if(channel_tag == "" || version.suite == 3)
		world.TgsTargetedChatBroadcast(message, admin_only)
		return

	var/list/channels_to_use = list()
	for(var/I in world.TgsChatChannelInfo())
		var/datum/tgs_chat_channel/channel = I
		var/list/applicable_tags = splittext(channel.custom_tag, ",")
		if((!admin_only || channel.is_admin_channel) && (channel_tag in applicable_tags))
			channels_to_use += channel

	if(channels_to_use.len)
		world.TgsChatBroadcast(message, channels_to_use)

/**
 * Asynchronously sends a message to TGS admin chat channels.
 *
 * category - The category of the mssage.
 * message - The message to send.
 */
/proc/send2adminchat(category, message, embed_links = FALSE)
	set waitfor = FALSE

	category = replacetext(replacetext(category, "\proper", ""), "\improper", "")
	message = replacetext(replacetext(message, "\proper", ""), "\improper", "")
	if(!embed_links)
		message = GLOB.has_discord_embeddable_links.Replace(replacetext(message, "`", ""), " ```$1``` ")
	world.TgsTargetedChatBroadcast(new /datum/tgs_message_content("[category] | [message]"), TRUE)

/// Handles text formatting for item use hints in examine text
#define EXAMINE_HINT(text) ("<b>" + text + "</b>")

/// Sends a message to all dead and observing players, if a source is provided a follow link will be attached.
/proc/send_to_observers(message, source, message_type = null)
	var/list/all_observers = GLOB.dead_player_list + GLOB.current_observers_list
	for(var/mob/observer as anything in all_observers)
		if (isnull(source))
			to_chat(observer, "[message]", type = message_type)
			continue
		var/link = FOLLOW_LINK(observer, source)
		to_chat(observer, "[link] [message]", type = message_type)

/// Sends a message to everyone within the list, as well as all observers.
/proc/relay_to_list_and_observers(message, list/mob_list, source, message_type = null)
	for(var/mob/creature as anything in mob_list)
		to_chat(creature, message, type = message_type)
	send_to_observers(message, source)
