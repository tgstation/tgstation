/datum/admins/proc/stickyban(action,data)
	if(!check_rights(R_BAN))
		return
	switch (action)
		if ("show")
			stickyban_show()
		if ("add")
			var/list/ban = list()
			ban["admin"] = usr.key
			ban["type"] = "sticky"
			ban["reason"] = "(InGameBan)([usr.key])" //this will be display in dd only
			var/ckey
			if (data["ckey"])
				ckey = data["ckey"]
			else
				ckey = input(usr,"Ckey","Ckey","") as text|null
				if (!ckey)
					return
				ckey = ckey(ckey)
			if (ckey in world.GetConfig("ban"))
				usr << "Can not add a stickyban: User already has a current sticky ban"
			if (data["reason"])
				ban["message"] = data["reason"]
			else
				var/reason = input(usr,"Reason","Reason","Ban Evasion") as text|null
				if (!reason)
					return
				ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2params(ban))

			log_admin("[key_name(usr)] has stickybanned [ckey].\nReason: [ban["message"]]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has stickybanned [ckey].\nReason: [ban["message"]]</span>")

		if ("remove")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]

			if (!(ckey in world.GetConfig("ban")))
				alert("No sticky ban for [ckey] found!")
				return
			var/ban = params2list(world.GetConfig("ban",ckey))
			if (!is_stickyban_from_game(ban))
				alert("This user was stickybanned by the host, and can not be un-stickybanned from this panel")
				return
			if (alert("Are you sure you want to remove the sticky ban on [ckey]?","Are you sure","Yes","No") == "No")
				return

			world.SetConfig("ban",ckey, null)

			log_admin("[key_name(usr)] removed [ckey]'s stickyban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] removed [ckey]'s stickyban</span>")

		if ("remove_alt")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (!data["alt"])
				return
			var/alt = ckey(data["alt"])
			if (!(ckey in world.GetConfig("ban")))
				alert("No sticky ban for [ckey] found!")
				return

			if (alert("Are you sure you want to disassociate [alt] from [ckey]'s sticky ban? \nNote: Nothing stops byond from re-linking them","Are you sure","Yes","No") == "No")
				return

			var/ban = params2list(world.GetConfig("ban",ckey))
			if (!is_stickyban_from_game(ban))
				alert("This user was stickybanned by the host, and can not be edited from this panel")
				return

			var/found = 0

			//we have to do it this way because byond keeps the case in its sticky ban matches WHY!!!
			for (var/key in ban["keys"])
				if (ckey(key) == alt)
					found = 1
					ban["keys"] -= key
					break

			if (!found)
				alert("[alt] is not linked to [ckey]'s sticky ban!")
				return

			world.SetConfig("ban",ckey,list2params(ban))

			log_admin("[key_name(usr)] has disassociated [alt] from [ckey]'s sticky ban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disassociated [alt] from [ckey]'s sticky ban</span>")
		if ("edit")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]

			if (!(ckey in world.GetConfig("ban")))
				alert("No sticky ban for [ckey] found!")
				return
			var/ban = params2list(world.GetConfig("ban",ckey))
			if (!is_stickyban_from_game(ban))
				alert("This user was stickybanned by the host, and can not be edited from this panel")
				return
			var/oldreason = ban["message"]
			var/reason = input(usr,"Reason","Reason","[ban["message"]]") as text|null
			if (!reason || reason == oldreason)
				return
			//we have to do this again incase something changed while we waited for input
			ban = params2list(world.GetConfig("ban",ckey))
			ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2params(ban))

			log_admin("[key_name(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]</span>")

/datum/admins/proc/stickyban_gethtml(ckey, ban)
	. = "<a href='?_src_=holder;stickyban=remove&ckey=[ckey]'>\[-\]</a><b>[ckey]</b><br />"
	. += "[ban["message"]] <b><a href='?_src_=holder;stickyban=edit&ckey=[ckey]'>\[Edit\]</a></b><br />"
	if (!is_stickyban_from_game(ban))
		. += "HOST<br />"
	if (ban["admin"])
		. += "[ban["admin"]]<br />"
	else
		. += "LEGACY<br />"
	. += "Caught keys<br />\n<ol>"
	for (var/key in ban["keys"])
		if (ckey(key) == ckey)
			continue
		. += "<li><a href='?_src_=holder;stickyban=remove_alt&ckey=[ckey]&alt=[ckey(key)]'>\[-\]</a>[key]</li>"
	. += "</ol>\n"

/datum/admins/proc/stickyban_show()
	if(!check_rights(R_BAN))
		return
	var/list/bans = world.GetConfig("ban")
	var/banhtml = ""
	for(var/ckey in bans)
		var/ban = params2list(world.GetConfig("ban",ckey))
		if (banhtml != "") //no need to do a border above the first ban.
			banhtml += "<br><hr/></br>\n"
		banhtml += stickyban_gethtml(ckey,ban)

	var/html = {"
	<head>
		<title>Sticky Bans</title>
	</head>
	<body>
		<b>All Sticky Bans:</b> <a href='?_src_=holder;stickyban=add'>\[+\]</a><br>
		[banhtml]
	</body>
	"}
	usr << browse(html,"window=stickybans;size=700x400")

//returns true if and only if the game added the sticky ban.
/proc/is_stickyban_from_game(ban)
	if (!ban || !islist(ban))
		return 0
	if (ban["type"] != "sticky")
		return 0
	if (copytext(ban["reason"],1,12) != "(InGameBan)")
		return 0
	return 1

/client/proc/stickybanpanel()
	set name = "Sticky Ban Panel"
	set category = "Admin"
	if (!holder)
		return
	holder.stickyban_show()