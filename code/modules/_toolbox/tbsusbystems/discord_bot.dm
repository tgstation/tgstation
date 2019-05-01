//****************************
//Discord Bot Subsystem Ticker
//****************************

SUBSYSTEM_DEF(discord_bot)
	name = "Discord Bot"
	runlevels = (RUNLEVEL_LOBBY|RUNLEVEL_SETUP|RUNLEVEL_GAME|RUNLEVEL_POSTGAME)
	var/last_status_report = 0
	var/status_report_interval = 60
	var/list/discord_commands = list()
	var/list/discord_roles = list(
		"280754671394750465" = "@everyone",
		"281156087904731136" = "Discord Moderator",
		"281155991540858881" = "Game Admin",
		"281156121836650499" = "Discord Administrator",
		"281156021961883649" = "Trial Admin",
		"281155888213917696" = "Host",
		"281156046523858945" = "Moderator",
		"281155835500167188" = "Game Master",
		"389911328514375681" = "The Craptaker",
		"513737392641933332" = "Role modification")

/datum/controller/subsystem/discord_bot/PreInit()
	. = ..()
	if(!discord_commands || !discord_commands.len)
		discord_commands = list()
		for(var/t in typesof(/datum/discord_command))
			var/datum/discord_command/D = new t()
			if(!D.command || !istext(D.command))
				qdel(D)
				continue
			discord_commands[D.command] = D

/datum/controller/subsystem/discord_bot/Shutdown()
	. = ..()
	var/list/filelist = flist("data/discordbot/commands/")
	for(var/file in filelist)
		var/f = "data/discordbot/commands/"+file
		if(!findtextEx(f,"txt",length(f)-3,length(f)+1))
			continue
		if(fexists(f))
			fdel(f)

/datum/controller/subsystem/discord_bot/fire(resumed)
	if(CONFIG_GET(flag/use_discord_bot))
		//Server status file
		/*if(!last_status_report || (last_status_report+(status_report_interval*10) <= world.time))
			last_status_report = world.time
			if(fexists("data/discordbot/statics/server_status.txt"))
				fdel("data/discordbot/statics/server_status.txt")
			var/list/reports = list()
			var/lastcheck = time2text(world.timeofday,"hh:mm:ss")
			if(lastcheck)
				reports += "Last Update: **[lastcheck](GMT)**"
			if(SSticker)
				var/thestate = null
				if(SSticker.current_state < GAME_STATE_PLAYING)
					thestate = "New Round Starting"
				else if (SSticker.current_state > GAME_STATE_PLAYING)
					thestate = "Round Finished"
				else
					var/worldtime = max(world.time-SSticker.round_start_time,0)
					var/hours = 0
					var/minutes = 0
					var/timeout = 24
					while(worldtime >= 36000 && timeout > 0)
						timeout--
						hours++
						worldtime -= 36000
					timeout = 59
					while(worldtime >= 600 && timeout > 0)
						timeout--
						minutes++
						worldtime -= 600
					if(minutes >= 300)
						minutes++
					if(length("[minutes]") < 2)
						minutes = "0[minutes]"
					thestate = "Round Active: **[hours]h [minutes]m**"
				if(thestate)
					reports += "Game State: **[thestate]**"
			if(GLOB)
				if(GLOB.round_id)
					reports += "Round ID: **[GLOB.round_id]**"
				reports += "Players online: **[GLOB.clients.len]**"
			var/report = "{"
			var/line = 1
			for(var/R in reports)
				report += "[line]:\"[R]\""
				if(line != reports.len)
					report += ","
				line++
			report += "}"
			var/thefile = file("data/discordbot/statics/server_status.txt")
			if(thefile)
				thefile << "[report]"*/
		//Reading commands from the discord bot
		var/list/filelist = flist("data/discordbot/commands/")
		if(istype(filelist,/list) && filelist.len)
			for(var/file in filelist)
				if(!findtextEx(file,"txt",length(file)-3,length(file)+1))
					continue
				var/f = "data/discordbot/commands/"+file
				if(fexists(f))
					var/filecontents = file2text(f)
					fdel(f)
					var/thechid = get_chid_position(filecontents)
					if(!isnum(thechid) || thechid <= 0)
						continue
					var/themessage = "[copytext(filecontents,1,thechid-1)]}"
					themessage = json_decode(themessage)
					themessage = themessage["msg"]
					if(!themessage || !istext(themessage))
						themessage = ""
					var/list/therest = "{[copytext(filecontents,thechid,length(filecontents)+1)]"
					therest = json_decode(therest)
					if(istype(therest) && therest.len)
						if(therest["roles"])
							therest["roles"] = repair_killings_code(therest["roles"])
						if((therest["chid"]) && (therest["username"]) && (therest["userid"]))
							for(var/command in discord_commands)
								if(command && findtext(themessage,command,1,length(themessage)+1))
									var/datum/discord_command/D = discord_commands[command]
									if(!istype(D))
										continue
									D.run_command(message = themessage, channel = therest["chid"], discorduser = therest["username"], discorduserid = therest["userid"], roles = therest["roles"])

/datum/controller/subsystem/discord_bot/proc/get_chid_position(jsontext)
	if(!istext(jsontext))
		return 0
	var/thenumber = length(jsontext)
	while(thenumber > 0)
		var/thetext = copytext(jsontext,thenumber,length(jsontext)+1)
		var/thechid = findtext(thetext,"\"chid\":",1,length(thetext)+1)
		if(thechid)
			return length(jsontext) - length(thetext)+1
		thenumber--
	return 0

//unnecessary lists in lists needs to be fixed lol
/datum/controller/subsystem/discord_bot/proc/repair_killings_code(list/roles)
	var/list/output = list()
	if(istype(roles,/list))
		for(var/t in roles)
			if(istype(t,/list))
				output += "[t["roleid"]]"
	return output

//The commands
/datum/discord_command
	var/command = null
	var/list/requires_all_these_roles = list()
	var/list/requires_one_of_these_roles = list()

/datum/discord_command/proc/run_command(message,channel,discorduser,discorduserid,list/roles)
	if(!message || !channel || !discorduser || !roles)
		return
	if(roles.len)
		var/list/matched_all_roles = list()
		var/list/matched_any_roles = list()
		for(var/role in roles)
			if(role in SSdiscord_bot.discord_roles &&  SSdiscord_bot.discord_roles[role] in requires_all_these_roles)
				matched_all_roles += role
			if(role in SSdiscord_bot.discord_roles &&  SSdiscord_bot.discord_roles[role] in requires_one_of_these_roles)
				matched_any_roles  += role
		if(requires_all_these_roles.len != matched_all_roles.len)
			return
		if(requires_one_of_these_roles.len >= 1 && matched_any_roles < 1)
			return
	activate(message,channel,discorduser,discorduserid,roles)

/datum/discord_command/proc/activate(message,channel,discorduser,discorduserid,roles)

//"!players".  calls how many players are online
/datum/discord_command/get_players
	command = "!players"

/datum/discord_command/get_players/activate(message,channel,discorduser,discorduserid,roles)
	var/playercount = 0
	for(var/client/C in GLOB.clients)
		playercount++
	for(var/c in GLOB.discord_channels)
		if(channel == GLOB.discord_channels[c])
			send_to_discord_channel(c,"**Toolbox Station Server** currently has **[playercount]** player[playercount == 1 ? "" : "s"] online. [GLOB && GLOB.round_id ? " ***(Round ID: [GLOB.round_id])***" : ""]")
			break

