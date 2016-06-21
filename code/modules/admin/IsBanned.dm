//Blocks an attempt to connect before even creating our client datum thing.

/world/IsBanned(key,address,computer_id)
	if (!key || !address || !computer_id)
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")
	
	if (text2num(computer_id) == 2147483647) //this cid causes stickybans to go haywire 
		log_access("Failed Login (invalid cid): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.)")
	var/admin = 0
	var/ckey = ckey(key)
	if((ckey in admin_datums) || (ckey in deadmins))
		admin = 1

	//Guest Checking
	if(IsGuestKey(key))
		if (!guests_allowed)
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (config.panic_bunker && dbcon && dbcon.IsConnected())
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	if(config.extreme_popcap && living_player_count() >= config.extreme_popcap && !admin)
		log_access("Failed Login: [key] - Population cap reached")
		return list("reason"="popcap", "desc"= "\nReason: [config.extreme_popcap_message]")

	if(config.ban_legacy_system)

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

		if(!establish_db_connection())
			world.log << "Ban database connection failure. Key [ckeytext] not checked"
			diary << "Ban database connection failure. Key [ckeytext] not checked"
			return

		var/ipquery = ""
		var/cidquery = ""
		if(address)
			ipquery = " OR ip = '[address]' "

		if(computer_id)
			cidquery = " OR computerid = '[computer_id]' "

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM [format_table_name("ban")] WHERE (ckey = '[ckeytext]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN' OR bantype = 'ADMIN_PERMABAN' OR ((bantype = 'TEMPBAN' OR bantype = 'ADMIN_TEMPBAN') AND expiration_time > Now())) AND isnull(unbanned)")

		query.Execute()

		while(query.NextRow())
			var/pckey = query.item[1]
			//var/pip = query.item[2]
			//var/pcid = query.item[3]
			var/ackey = query.item[4]
			var/reason = query.item[5]
			var/expiration = query.item[6]
			var/duration = query.item[7]
			var/bantime = query.item[8]
			var/bantype = query.item[9]
			if (bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
				//admin bans MUST match on ckey to prevent cid-spoofing attacks
				//	as well as dynamic ip abuse
				if (pckey != ckey)
					continue
			if (admin)
				if (bantype == "ADMIN_PERMABAN" || bantype == "ADMIN_TEMPBAN")
					log_admin("The admin [key] is admin banned, and has been disallowed access")
					message_admins("<span class='adminnotice'>The admin [key] is admin banned, and has been disallowed access</span>")
				else
					log_admin("The admin [key] has been allowed to bypass a matching ban on [pckey]")
					message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching ban on [pckey]</span>")
					addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching ban on [pckey]</span>")
					continue
			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."
			else
				expires = " The is a permanent ban."

			var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime], [expires]"

			. = list("reason"="[bantype]", "desc"="[desc]")


			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			return .

	. = ..()	//default pager ban stuff
	if (.)
		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if (admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban")
			message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching host/sticky ban</span>")
			addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching host/sticky ban</span>")
			return null
		else
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["message"]]")

	return .
