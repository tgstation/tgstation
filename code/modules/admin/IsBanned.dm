//Blocks an attempt to connect before even creating our client datum thing.

world/IsBanned(key,address,computer_id)
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

			var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM erro_ban WHERE (ckey = '[ckeytext]') AND (bantype = 'ADMIN_PERMABAN'  OR (bantype = 'ADMIN_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")

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
	if(!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("<span class='adminnotice'>Failed Login: [key] - Guests not allowed</span>")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")

	if(config.ban_legacy_system)

		//Ban Checking
		. = CheckBan( ckey(key), computer_id, address )
		if(.)
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			message_admins("<span class='adminnotice'>Failed Login: [key] id:[computer_id] ip:[address] - Banned [.["reason"]]</span>")
			return .

		return ..()	//default pager ban stuff

	else

		var/ckeytext = ckey(key)

		if(!establish_db_connection())
			world.log << "Ban database connection failure. Key [ckeytext] not checked"
			diary << "Ban database connection failure. Key [ckeytext] not checked"
			return

		var/failedcid = 1
		var/failedip = 1

		var/ipquery = ""
		var/cidquery = ""
		if(address)
			failedip = 0
			ipquery = " OR ip = '[address]' "

		if(computer_id)
			failedcid = 0
			cidquery = " OR computerid = '[computer_id]' "

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM erro_ban WHERE (ckey = '[ckeytext]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN'  OR (bantype = 'TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")

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

		if (failedcid)
			message_admins("[key] has logged in with a blank computer id in the ban check.")
		if (failedip)
			message_admins("[key] has logged in with a blank ip in the ban check.")
		return ..()	//default pager ban stuff
