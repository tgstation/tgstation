//***********
//Discord Bot
//***********
/*This is for sending commands to killing torchers discord bot. The process is simple, call the proc send_to_discord_channel( "Discord Channel Name" , "Message")
This creates a text file at the file location of DISCORDBOTFILE_MESSAGE. The discord bot uses this to read commands from the file then deletes the file.*/

#define DISCORDBOTFILE_MESSAGE "data/discordbot/messages"

//Config entry to eneble discord bot interaction
/datum/config_entry/flag/use_discord_bot

GLOBAL_LIST_EMPTY(discord_channels)

/proc/initialize_discord_channel_list()
	//GLOB.discord_channels["#rules"] = "280754671394750465"
	//GLOB.discord_channels["#join_server"] = "500308063274663936"
	//GLOB.discord_channels["#info_adminhelp"] = "323737110953590784"
	//GLOB.discord_channels["#update_history"] = "400297312473186305"
	GLOB.discord_channels["#general"] = "280768322578939925"
	GLOB.discord_channels["#stories"] = "281155594092675072"
	GLOB.discord_channels["#suggestions"] = "424951241693462548"
	GLOB.discord_channels["#memes"] = "357242959474851842"
	GLOB.discord_channels["#offtopic"] = "500326039210295307"
	GLOB.discord_channels["#shitposting"] = "500327265356480518"
	GLOB.discord_channels["#admin_log"] = "288459972034166784"
	GLOB.discord_channels["#admin_help"] = "525084131256827916"
	GLOB.discord_channels["#admin_discussion"] = "325394561323237376"
	//GLOB.discord_channels["#fullmins_only"] = "344499705499090945"
	//GLOB.discord_channels["#founderchat"] = "344499881601400832"
	GLOB.discord_channels["#new_round_notifications"] = "526419363918512149"
	GLOB.discord_channels["#killingfuckswithbot"] = "525350221337591808"

/proc/send_to_discord_channel(channel,message)
	if(!CONFIG_GET(flag/use_discord_bot)||!channel||!message||!istext(message)||!GLOB)
		return 0
	var/channelid
	if(copytext(channel,1,2) == "#")
		if(GLOB.discord_channels[channel])
			channelid = GLOB.discord_channels[channel]
	else
		for(var/t in GLOB.discord_channels)
			if(GLOB.discord_channels[t] == channel)
				channelid = channel
				break
	if(!channelid)
		return 0
	message = sanitize_simple(message,repl_chars = list("\\"="\\u005c", ","="\\u002c", "\"" = "\\u0022"))
	var/thedate = "[time2text(world.realtime,"YYYY_MM_DD_hh_mm_ss")]"
	var/filename = "discordfile_[thedate]"
	var/repeatnumber = 0
	if(fexists("[filename].txt"))
		repeatnumber = 1
		var/timeout = 200
		while(fexists("[filename]([repeatnumber]).txt"))
			repeatnumber++
			timeout--
			if(timeout <= 0)
				return
	if(repeatnumber > 0)
		filename = "[filename]([repeatnumber])"
	filename = "[DISCORDBOTFILE_MESSAGE]/[filename].txt"
	var/thefile = file(filename)
	if(thefile)
		thefile << "{\"msg\":\"[message]\", \"chid\":\"[channelid]\"}"
		return 1
	return 0

/datum/admins/proc/discord_bot_message()
	set name = "Send Discord Message"
	set category = "Server"
	if(!GLOB || !GLOB.discord_channels)
		to_chat(usr,"Can not find discord channels.")
		return
	var/thechannel = input(usr,"Pick a Discord channel.","Send Discord Message",null) as null|anything in GLOB.discord_channels
	if(!thechannel || !GLOB.discord_channels[thechannel])
		to_chat(usr,"Can not find discord channels.")
		return
	var/themessage = input(usr,"Enter Message.","Send Discord Message",null) as text
	if(themessage && thechannel)
		send_to_discord_channel(thechannel,themessage)

/proc/send_admin_notice_to_discord(Message, Title = "AdminHelp", Channel = "#admin_help", zeroadmins = 1)
	send_to_discord_channel(Channel,"_**[Title]**_ [Message ? "[Message] " : ""]***(Round ID: [GLOB.round_id][zeroadmins ? ", 0 admins online" : ""])***")