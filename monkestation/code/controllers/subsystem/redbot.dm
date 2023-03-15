SUBSYSTEM_DEF(redbot)
	name = "Bot Comms"
	flags = SS_NO_FIRE

/datum/controller/subsystem/redbot/Initialize(timeofday)
	var/comms_key = CONFIG_GET(string/bot_key)
	var/bot_ip = CONFIG_GET(string/bot_ip)
	var/round_id = GLOB.round_id
	if(config && bot_ip)
		var/query = "http://[bot_ip]/?serverStart=1&roundID=[round_id]&key=[comms_key]"
		world.Export(query)
	return ..()

/datum/controller/subsystem/redbot/proc/send_discord_message(var/channel, var/message, var/priority_type)
	var/bot_ip = CONFIG_GET(string/bot_ip)
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	. = allmins.len
	if(!config || !bot_ip)
		return
	if(priority_type && !.)
		send_discord_message(channel, "@here - A new [priority_type] requires/might need attention, but there are no admins online.") //Backup message should redbot be unavailable
	var/list/data = list()
	data["key"] = CONFIG_GET(string/bot_key)
	data["announce_channel"] = channel
	data["announce"] = message
	world.Export("http://[bot_ip]/?[list2params(data)]")
