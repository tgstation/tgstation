/datum/world_topic/fixtts
	keyword = "fixtts"
	require_comms_key = TRUE

/datum/world_topic/fixtts/Run(list/input)
	var/datum/tts_provider/silero = SStts220.tts_providers["Silero"]
	log_topic("SStts220.tts_providers\[Silero].is_enabled = [silero.is_enabled]")
	if(!silero.is_enabled)
		silero.is_enabled = TRUE
		silero.failed_requests_limit += initial(silero.failed_requests_limit)
		to_chat(world, "<span class='announce'>SERVER: провайдер Silero в подсистеме SStts220 принудительно включен!</span>")
		return list("success" = "SStts220\[Silero] was force enabled")

	return list("error" = "SStts220\[Silero] is already enabled")

/datum/world_topic/playerlist
	keyword = "playerlist"

/datum/world_topic/playerlist/Run(list/input)
	var/list/keys = list()
	for(var/I in GLOB.clients)
		var/client/C = I
		keys += C.key

	return keys

/datum/world_topic/status/Run(list/input)
	. = ..()
	var/list/admins = list()
	for(var/client/C in GLOB.clients)
		if(!C.holder)
			continue

		if(C.holder.fakekey)
			continue	//so stealthmins aren't revealed by the hub

		admins += list(list(C.key, join_admin_ranks(C.holder.ranks)))

	if(key_valid)
		for(var/i in 1 to admins.len)
			var/list/A = admins[i]
			.["admin[i - 1]"] = A[1]
			.["adminrank[i - 1]"] = A[2]

/datum/world_topic/adminwho/Run(list/input)
	var/list/out_data = list()
	for(var/client/admin_client as anything in GLOB.admins)
		var/list/this_entry = list()
		// Send both incase we want special formatting
		this_entry["ckey"] = admin_client.ckey
		this_entry["key"] = admin_client.key
		this_entry["rank"] = admin_client.holder.ranks.Join("/")
		// is_afk() returns an int of inactivity, we can use this to determine AFK for how long
		// This info will not be shown in public channels
		this_entry["afk"] = admin_client.is_afk()
		if(admin_client.holder.fakekey)
			this_entry["stealth"] = "STEALTH"
			this_entry["skey"] = admin_client.holder.fakekey
		else
			this_entry["stealth"] = "NONE"
			this_entry["skey"] = "NONE"

		out_data += list(this_entry)

	return out_data
