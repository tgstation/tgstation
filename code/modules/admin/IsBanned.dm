//Blocks an attempt to connect before even creating our client datum thing.

//How many new ckey matches before we revert the stickyban to it's roundstart state
//These are exclusive, so once it goes over one of these numbers, it reverts the ban
#define STICKYBAN_MAX_MATCHES 20
#define STICKYBAN_MAX_EXISTING_USER_MATCHES 5 //ie, users who were connected before the ban triggered
#define STICKYBAN_MAX_ADMIN_MATCHES 2

/world/IsBanned(key,address,computer_id,type,real_bans_only=FALSE)
	if (!key || !address || !computer_id)
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	if (text2num(computer_id) == 2147483647) //this cid causes stickybans to go haywire
		log_access("Failed Login (invalid cid): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.)")
	var/admin = 0
	var/ckey = ckey(key)
	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = 1

	//Whitelist
	if(CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey(key)))
			if (admin)
				log_admin("The admin [key] has been allowed to bypass the whitelist")
				message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass the whitelist</span>")
				addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass the whitelist</span>")
			else
				log_access("Failed Login: [key] - Not on whitelist")
				return list("reason"="whitelist", "desc" = "\nReason: You are not on the white list for this server")

	//Guest Checking
	if(!real_bans_only && IsGuestKey(key))
		if (CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect())
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(!real_bans_only && extreme_popcap && living_player_count() >= extreme_popcap && !admin)
		log_access("Failed Login: [key] - Population cap reached")
		return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

	if(CONFIG_GET(flag/ban_legacy_system))

		//Ban Checking
		. = CheckBan( ckey(key), computer_id, address )
		if(.)
			if (admin)
				log_admin("The admin [key] has been allowed to bypass a matching ban on [.["key"]]")
				message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [.["key"]]</span>")
				addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [.["key"]]</span>")
			else
				log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
				return .

	else

		var/ckeytext = ckey(key)

		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckeytext] not checked"
			log_world(msg)
			message_admins(msg)
			return

		var/ipquery = ""
		var/cidquery = ""
		if(address)
			ipquery = " OR ip = INET_ATON('[address]') "

		if(computer_id)
			cidquery = " OR computerid = '[computer_id]' "

		var/datum/DBQuery/query_ban_check = SSdbcore.NewQuery("SELECT ckey, a_ckey, reason, expiration_time, duration, bantime, bantype, id, round_id FROM [format_table_name("ban")] WHERE (ckey = '[ckeytext]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN' OR bantype = 'ADMIN_PERMABAN' OR ((bantype = 'TEMPBAN' OR bantype = 'ADMIN_TEMPBAN') AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query_ban_check.Execute(async = TRUE))
			qdel(query_ban_check)
			return
		while(query_ban_check.NextRow())
			var/pckey = query_ban_check.item[1]
			var/ackey = query_ban_check.item[2]
			var/reason = query_ban_check.item[3]
			var/expiration = query_ban_check.item[4]
			var/duration = query_ban_check.item[5]
			var/bantime = query_ban_check.item[6]
			var/bantype = query_ban_check.item[7]
			var/banid = query_ban_check.item[8]
			var/ban_round_id = query_ban_check.item[9]
			if (bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
				//admin bans MUST match on ckey to prevent cid-spoofing attacks
				//	as well as dynamic ip abuse
				if (pckey != ckey)
					continue
			if (admin)
				if (bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
					log_admin("The admin [key] is admin banned (#[banid]), and has been disallowed access")
					message_admins("<span class='adminnotice'>The admin [key] is admin banned (#[banid]), and has been disallowed access</span>")
				else
					log_admin("The admin [key] has been allowed to bypass a matching ban on [pckey] (#[banid])")
					message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [pckey] (#[banid])</span>")
					addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [pckey] (#[banid])</span>")
					continue
			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."
			else
				expires = " The is a permanent ban."

			var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban (BanID #[banid]) was applied by [ackey] on [bantime] during round ID [ban_round_id], [expires]"

			. = list("reason"="[bantype]", "desc"="[desc]")


			log_access("Failed Login: [key] [computer_id] [address] - Banned (#[banid]) [.["reason"]]")
			qdel(query_ban_check)
			return .
		qdel(query_ban_check)

	var/list/ban = ..()	//default pager ban stuff
	if (ban)
		var/bannedckey = "ERROR"
		if (ban["ckey"])
			bannedckey = ban["ckey"]

		var/newmatch = FALSE
		var/client/C = GLOB.directory[ckey]
		var/cachedban = SSstickyban.cache[bannedckey]

		//rogue ban in the process of being reverted.
		if (cachedban && cachedban["reverting"])
			return null

		if (cachedban && ckey != bannedckey)
			newmatch = TRUE
			if (cachedban["keys"])
				if (cachedban["keys"][ckey])
					newmatch = FALSE
			if (cachedban["matches_this_round"][ckey])
				newmatch = FALSE

		if (newmatch && cachedban)
			var/list/newmatches = cachedban["matches_this_round"]
			var/list/newmatches_connected = cachedban["existing_user_matches_this_round"]
			var/list/newmatches_admin = cachedban["admin_matches_this_round"]

			newmatches[ckey] = ckey
			if (C)
				newmatches_connected[ckey] = ckey
			if (admin)
				newmatches_admin[ckey] = ckey

			if (\
				newmatches.len > STICKYBAN_MAX_MATCHES || \
				newmatches_connected.len > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
				newmatches_admin.len > STICKYBAN_MAX_ADMIN_MATCHES \
				)
				if (cachedban["reverting"])
					return null
				cachedban["reverting"] = TRUE

				world.SetConfig("ban", bannedckey, null)

				log_game("Stickyban on [bannedckey] detected as rogue, reverting to its roundstart state")
				message_admins("Stickyban on [bannedckey] detected as rogue, reverting to its roundstart state")
				//do not convert to timer.
				spawn (5)
					world.SetConfig("ban", bannedckey, null)
					sleep(1)
					world.SetConfig("ban", bannedckey, null)
					cachedban["matches_this_round"] = list()
					cachedban["existing_user_matches_this_round"] = list()
					cachedban["admin_matches_this_round"] = list()
					cachedban -= "reverting"
					world.SetConfig("ban", bannedckey, list2stickyban(cachedban))
				return null

		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if (admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]")
			message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
			addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
			return null

		if (C) //user is already connected!.
			to_chat(C, "You are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect using file -> reconnect to see if the match was reversed.")

		var/desc = "\nReason:(StickyBan) You, or another user of this computer or connection ([bannedckey]) is banned from playing here. The ban reason is:\n[ban["message"]]\nThis ban was applied by [ban["admin"]]\nThis is a BanEvasion Detection System ban, if you think this ban is a mistake, please wait EXACTLY 6 seconds, then try again before filing an appeal.\n"
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [ban["message"]] Target Username: [bannedckey] Placed by [ban["admin"]]")

	return .


#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
