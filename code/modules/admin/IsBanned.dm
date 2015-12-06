/world/IsBanned(key, address, computer_id)

	if (!key || !address || !computer_id)
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason" = "invalid login data", "desc" = "Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username: '[key]' IP: '[address]' Computer ID: '[computer_id]', If you continue to get this error, please restart byond or contact byond support.")
	if (computer_id == 2147483647) //this cid causes stickybans to go haywire 
		log_access("Failed Login (invalid cid): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.)")

	log_access("IsBanned: Checking [ckey(key)], [address], [computer_id]")
	//Guest Checking
	if(!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("<span class='notice'>Failed Login: [key] - Guests not allowed</span>")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")

	//check if the IP address is a known TOR node
	if(config && config.ToRban && ToRban_isbanned(address))
		log_access("Failed Login: [src] - Banned: ToR")
		message_admins("<span class='notice'>Failed Login: [src] - Banned: ToR</span>")
		//ban their computer_id and ckey for posterity
		AddBan(ckey(key), computer_id, "Use of ToR", "Automated Ban", 0, 0)
		return list("reason"="Using ToR", "desc"="\nReason: The network you are using to connect has been banned.\nIf you believe this is a mistake, please request help at [config.banappeals]")


	if(config.ban_legacy_system)
		//Ban Checking
		. = CheckBan( ckey(key), computer_id, address )
		if(.)
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			message_admins("<span class='notice'>Failed Login: [key] id:[computer_id] ip:[address] - Banned [.["reason"]]</span>")
			return .
		//sticky ban logging
		. = ..()
		var/list/what = .
		if(istype(what,/list))
			message_admins("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
			log_access("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
			var/desc
			if(config.banappeals)
				desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: Permanent \nExpires: Never \nAppeal: [config.banappeals]"
			else
				desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: Permanent \nExpires: Never \nAppeal: <span class='warning'>No ban appeals link set</span>"
				what.Remove("message")
				what["desc"] = "[desc]"
				what["reason"] = "Permanent"

		return .	//default pager ban stuff

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
			var/desc = ""
			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."
			if(config.banappeals)
				desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime] \nBan type: [bantype] \nExpires: [expires] \nAppeal: [config.banappeals]"
			else
				desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime] \nBan type: [bantype] \nExpires: [expires] \nAppeal: <span class='warning'>No ban appeals link set</span>"
			log_access("Failed Login: [key] [computer_id] [address] - Banned [desc]")
			return list("reason"="[bantype]", "desc"="[desc]")
			//return "[bantype][desc]"

		if (failedcid)
			message_admins("[key] has logged in with a blank computer id in the ban check.")
		if (failedip)
			message_admins("[key] has logged in with a blank ip in the ban check.")
		//sticky ban logging
		. = ..()
		var/list/what = .
		if(istype(what,/list))
			message_admins("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
			log_access("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
			var/desc
			if(config.banappeals)
				desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: Permanent \nExpires: Never \nAppeal: [config.banappeals]"
			else
				desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: Permanent \nExpires: Never \nAppeal: <span class='warning'>No ban appeals link set</span>"
				what.Remove("message")
				what["desc"] = "[desc]"
				what["reason"] = "Permanent"
		return .	//default pager ban stuff