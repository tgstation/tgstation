/datum/admins/proc/stickyban(action,data)
	if(!check_rights(R_BAN))
		return
	switch (action)
		if ("show")
			stickyban_show()
		if ("add")
			var/list/ban = list()
			var/ckey
			ban["admin"] = usr.key
			ban["type"] = list("sticky")
			ban["reason"] = "(InGameBan)([usr.key])" //this will be displayed in dd only

			if (data["ckey"])
				ckey = ckey(data["ckey"])
			else
				ckey = input(usr,"Ckey","Ckey","") as text|null
				if (!ckey)
					return
				ckey = ckey(ckey)
			ban["ckey"] = ckey

			if (get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='adminnotice'>Error: Can not add a stickyban: User already has a current sticky ban</span>")

			if (data["reason"])
				ban["message"] = data["reason"]
			else
				var/reason = input(usr,"Reason","Reason","Ban Evasion") as text|null
				if (!reason)
					return
				ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has stickybanned [ckey].\nReason: [ban["message"]]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has stickybanned [ckey].\nReason: [ban["message"]]</span>")

		if ("remove")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]

			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
				return
			if (alert("Are you sure you want to remove the sticky ban on [ckey]?","Are you sure","Yes","No") == "No")
				return
			if (!get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='adminnotice'>Error: The ban disappeared.</span>")
				return
			world.SetConfig("ban",ckey, null)

			log_admin_private("[key_name(usr)] removed [ckey]'s stickyban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] removed [ckey]'s stickyban</span>")

		if ("remove_alt")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (!data["alt"])
				return
			var/alt = ckey(data["alt"])
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
				return

			var/found = 0
			//we have to do it this way because byond keeps the case in its sticky ban matches WHY!!!
			for (var/key in ban["keys"])
				if (ckey(key) == alt)
					found = 1
					break

			if (!found)
				to_chat(usr, "<span class='adminnotice'>Error: [alt] is not linked to [ckey]'s sticky ban!</span>")
				return

			if (alert("Are you sure you want to disassociate [alt] from [ckey]'s sticky ban? \nNote: Nothing stops byond from re-linking them","Are you sure","Yes","No") == "No")
				return

			//we have to do this again incase something changes
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: The ban disappeared.</span>")
				return

			found = 0
			for (var/key in ban["keys"])
				if (ckey(key) == alt)
					ban["keys"] -= key
					found = 1
					break

			if (!found)
				to_chat(usr, "<span class='adminnotice'>Error: [alt] link to [ckey]'s sticky ban disappeared.</span>")
				return

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has disassociated [alt] from [ckey]'s sticky ban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disassociated [alt] from [ckey]'s sticky ban</span>")

		if ("edit")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
				return
			var/oldreason = ban["message"]
			var/reason = input(usr,"Reason","Reason","[ban["message"]]") as text|null
			if (!reason || reason == oldreason)
				return
			//we have to do this again incase something changed while we waited for input
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: The ban disappeared.</span>")
				return
			ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]</span>")

		if ("revert")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (alert("Are you sure you want to revert the sticky ban on [ckey] to its state at round start?","Are you sure","Yes","No") == "No")
				return
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Error: No sticky ban for [ckey] found!</span>")
				return
			var/cached_ban = SSstickyban.cache[ckey]
			if (!cached_ban)
				to_chat(usr, "<span class='adminnotice'>Error: No cached sticky ban for [ckey] found!</span>")
			world.SetConfig("ban",ckey,null)

			log_admin_private("[key_name(usr)] has reverted [ckey]'s sticky ban to its state at round start.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has reverted [ckey]'s sticky ban to its state at round start.</span>")
			//revert is mostly used when shit goes rouge, so we have to set it to null
			//	and wait a byond tick before assigning it to ensure byond clears its shit.
			sleep(world.tick_lag)
			world.SetConfig("ban",ckey,list2stickyban(cached_ban))


/datum/admins/proc/stickyban_gethtml(ckey, ban)
	. = {"
		<a href='?_src_=holder;[HrefToken()];stickyban=remove&ckey=[ckey]'>\[-\]</a>
		<a href='?_src_=holder;[HrefToken()];stickyban=revert&ckey=[ckey]'>\[revert\]</a>
		<b>[ckey]</b>
		<br />"
		[ban["message"]] <b><a href='?_src_=holder;[HrefToken()];stickyban=edit&ckey=[ckey]'>\[Edit\]</a></b><br />
	"}
	if (ban["admin"])
		. += "[ban["admin"]]<br />"
	else
		. += "LEGACY<br />"
	. += "Caught keys<br />\n<ol>"
	for (var/key in ban["keys"])
		if (ckey(key) == ckey)
			continue
		. += "<li><a href='?_src_=holder;[HrefToken()];stickyban=remove_alt&ckey=[ckey]&alt=[ckey(key)]'>\[-\]</a>[key]</li>"
	. += "</ol>\n"

/datum/admins/proc/stickyban_show()
	if(!check_rights(R_BAN))
		return
	var/list/bans = sortList(world.GetConfig("ban"))
	var/banhtml = ""
	for(var/key in bans)
		var/ckey = ckey(key)
		var/ban = stickyban2list(world.GetConfig("ban",key))
		banhtml += "<br /><hr />\n"
		banhtml += stickyban_gethtml(ckey,ban)

	var/html = {"
	<head>
		<title>Sticky Bans</title>
	</head>
	<body>
		<h2>All Sticky Bans:</h2> <a href='?_src_=holder;[HrefToken()];stickyban=add'>\[+\]</a><br>
		[banhtml]
	</body>
	"}
	usr << browse(html,"window=stickybans;size=700x400")

/proc/get_stickyban_from_ckey(var/ckey)
	if (!ckey)
		return null
	ckey = ckey(ckey)
	. = null
	for (var/key in world.GetConfig("ban"))
		if (ckey(key) == ckey)
			. = stickyban2list(world.GetConfig("ban",key))
			break

/proc/stickyban2list(var/ban)
	if (!ban)
		return null
	. = params2list(ban)
	if (.["keys"])
		var/keys = splittext(.["keys"], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.["keys"] = ckeys
	.["type"] = splittext(.["type"], ",")
	.["IP"] = splittext(.["IP"], ",")
	.["computer_id"] = splittext(.["computer_id"], ",")


/proc/list2stickyban(var/list/ban)
	if (!ban || !islist(ban))
		return null
	. = ban.Copy()
	if (.["keys"])
		.["keys"] = jointext(.["keys"], ",")
	if (.["type"])
		.["type"] = jointext(.["type"], ",")

	//internal tracking only, shouldn't be stored
	. -= "existing_user_matches_this_round"
	. -= "admin_matches_this_round"
	. -= "matches_this_round"
	. -= "reverting"

	//storing these can sometimes cause sticky bans to start matching everybody
	//	and isn't even needed for sticky ban matching, as the hub tracks these separately
	. -= "IP"
	. -= "computer_id"

	. = list2params(.)


/client/proc/stickybanpanel()
	set name = "Sticky Ban Panel"
	set category = "Admin"
	if (!holder)
		return
	holder.stickyban_show()
