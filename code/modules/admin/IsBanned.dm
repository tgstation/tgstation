//Blocks an attempt to connect before even creating our client datum thing.

world/IsBanned(key,address,computer_id)
	if (!key || !address || !computer_id)
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]' If you continue to get this error, please restart byond or contact byond support.")
	if(ckey(key) in admin_datums)
		//It has proven to be a bad idea to make admins completely immune to bans, making them have to wait for someone with daemon access
		//to add a daemon ban to finally stop them. Admin tempbans and admin permabans are special, high-level ban types, which are there to help
		//deal with rogue admins quicker. If admin tempbans or admin permabans are ever needed, it should be consider a big deal. The same applies if
		//admin bans are ever abused. This ban type does NOT check for IP or Computer ID. The reason for this is so a player cannot find/steal an admin's
		//computer id, set it on his computer, get himself banned, resulting in the admin getting banned aswell. - this happens to also be the reason why
		//admins were immune to bans in the first place.
		if(!config.ban_legacy_system)
			var/ckeytext = ckey(key)

			if(!establish_db_connection())
				world.log << "Ban database connection failure. Admin [ckeytext] not checked"
				diary << "Ban database connection failure. Admin [ckeytext] not checked"
				return

			var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM [format_table_name("ban")] WHERE (ckey = '[ckeytext]') AND (bantype = 'ADMIN_PERMABAN'  OR (bantype = 'ADMIN_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")

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

				var/expires = ""
				if(text2num(duration) > 0)
					expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."

				var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime], [expires]"

				return list("reason"="[bantype]", "desc"="[desc]")

		return ..()

	//Guest Checking
	if(IsGuestKey(key))
		if (!guests_allowed)
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (config.panic_bunker && dbcon && dbcon.IsConnected())
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	if(config.extreme_popcap && living_player_count() >= config.extreme_popcap && !(ckey(key) in admin_datums))
		log_access("Failed Login: [key] - Population cap reached")
		return list("reason"="popcap", "desc"= "\nReason: [config.extreme_popcap_message]")

	if(config.ban_legacy_system)

		//Ban Checking
		. = CheckBan( ckey(key), computer_id, address )
		if(.)
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			return .

		return ..()	//default pager ban stuff

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

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM [format_table_name("ban")] WHERE (ckey = '[ckeytext]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN'  OR (bantype = 'TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")

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

			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."

			var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime], [expires]"

			return list("reason"="[bantype]", "desc"="[desc]")
		return ..()	//default pager ban stuff
