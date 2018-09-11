GLOBAL_VAR(CMinutes)
GLOBAL_DATUM(Banlist, /savefile)
GLOBAL_PROTECT(Banlist)


/proc/CheckBan(ckey, id, address)
	if(!GLOB.Banlist)		// if Banlist cannot be located for some reason
		LoadBans()		// try to load the bans
		if(!GLOB.Banlist)	// uh oh, can't find bans!
			return 0	// ABORT ABORT ABORT

	. = list()
	var/appeal
	var/bran = CONFIG_GET(string/banappeals)
	if(bran)
		appeal = "\nFor more information on your ban, or to appeal, head to <a href='[bran]'>[bran]</a>"
	GLOB.Banlist.cd = "/base"
	if( "[ckey][id]" in GLOB.Banlist.dir )
		GLOB.Banlist.cd = "[ckey][id]"
		if (GLOB.Banlist["temp"])
			if (!GetExp(GLOB.Banlist["minutes"]))
				ClearTempbans()
				return 0
			else
				.["desc"] = "\nReason: [GLOB.Banlist["reason"]]\nExpires: [GetExp(GLOB.Banlist["minutes"])]\nBy: [GLOB.Banlist["bannedby"]] during round ID [GLOB.Banlist["roundid"]][appeal]"
		else
			GLOB.Banlist.cd	= "/base/[ckey][id]"
			.["desc"]	= "\nReason: [GLOB.Banlist["reason"]]\nExpires: <B>PERMANENT</B>\nBy: [GLOB.Banlist["bannedby"]] during round ID [GLOB.Banlist["roundid"]][appeal]"
		.["reason"]	= "ckey/id"
		return .
	else
		for (var/A in GLOB.Banlist.dir)
			GLOB.Banlist.cd = "/base/[A]"
			var/matches
			if( ckey == GLOB.Banlist["key"] )
				matches += "ckey"
			if( id == GLOB.Banlist["id"] )
				if(matches)
					matches += "/"
				matches += "id"
			if( address == GLOB.Banlist["ip"] )
				if(matches)
					matches += "/"
				matches += "ip"

			if(matches)
				if(GLOB.Banlist["temp"])
					if (!GetExp(GLOB.Banlist["minutes"]))
						ClearTempbans()
						return 0
					else
						.["desc"] = "\nReason: [GLOB.Banlist["reason"]]\nExpires: [GetExp(GLOB.Banlist["minutes"])]\nBy: [GLOB.Banlist["bannedby"]] during round ID [GLOB.Banlist["roundid"]][appeal]"
				else
					.["desc"] = "\nReason: [GLOB.Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [GLOB.Banlist["bannedby"]] during round ID [GLOB.Banlist["roundid"]][appeal]"
				.["reason"] = matches
				return .
	return 0

/proc/UpdateTime() //No idea why i made this a proc.
	GLOB.CMinutes = (world.realtime / 10) / 60
	return 1

/proc/LoadBans()

	GLOB.Banlist = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if (!length(GLOB.Banlist.dir))
		log_admin("Banlist is empty.")

	if (!GLOB.Banlist.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		GLOB.Banlist.dir.Add("base")
		GLOB.Banlist.cd = "/base"
	else if (GLOB.Banlist.dir.Find("base"))
		GLOB.Banlist.cd = "/base"

	ClearTempbans()
	return 1

/proc/ClearTempbans()
	UpdateTime()

	GLOB.Banlist.cd = "/base"
	for (var/A in GLOB.Banlist.dir)
		GLOB.Banlist.cd = "/base/[A]"
		if (!GLOB.Banlist["key"] || !GLOB.Banlist["id"])
			RemoveBan(A)
			log_admin("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue

		if (!GLOB.Banlist["temp"])
			continue
		if (GLOB.CMinutes >= GLOB.Banlist["minutes"])
			RemoveBan(A)

	return 1


/proc/AddBan(key, computerid, reason, bannedby, temp, minutes, address)

	var/bantimestamp
	var/ban_ckey = ckey(key)
	if (temp)
		UpdateTime()
		bantimestamp = GLOB.CMinutes + minutes

	GLOB.Banlist.cd = "/base"
	if ( GLOB.Banlist.dir.Find("[ban_ckey][computerid]") )
		to_chat(usr, text("<span class='danger'>Ban already exists.</span>"))
		return 0
	else
		GLOB.Banlist.dir.Add("[ban_ckey][computerid]")
		GLOB.Banlist.cd = "/base/[ban_ckey][computerid]"
		WRITE_FILE(GLOB.Banlist["key"], ban_ckey)
		WRITE_FILE(GLOB.Banlist["id"], computerid)
		WRITE_FILE(GLOB.Banlist["ip"], address)
		WRITE_FILE(GLOB.Banlist["reason"], reason)
		WRITE_FILE(GLOB.Banlist["bannedby"], bannedby)
		WRITE_FILE(GLOB.Banlist["temp"], temp)
		WRITE_FILE(GLOB.Banlist["roundid"], GLOB.round_id)
		if (temp)
			WRITE_FILE(GLOB.Banlist["minutes"], bantimestamp)
		if(!temp)
			create_message("note", key, bannedby, "Permanently banned - [reason]", null, null, 0, 0, null, 0, 0)
		else
			create_message("note", key, bannedby, "Banned for [minutes] minutes - [reason]", null, null, 0, 0, null, 0, 0)
	return 1

/proc/RemoveBan(foldername)
	var/key
	var/id

	GLOB.Banlist.cd = "/base/[foldername]"
	GLOB.Banlist["key"] >> key
	GLOB.Banlist["id"] >> id
	GLOB.Banlist.cd = "/base"

	if (!GLOB.Banlist.dir.Remove(foldername))
		return 0

	if(!usr)
		log_admin_private("Ban Expired: [key]")
		message_admins("Ban Expired: [key]")
	else
		ban_unban_log_save("[key_name(usr)] unbanned [key]")
		log_admin_private("[key_name(usr)] unbanned [key]")
		message_admins("[key_name_admin(usr)] unbanned: [key]")
		usr.client.holder.DB_ban_unban( ckey(key), BANTYPE_ANY_FULLBAN)
	for (var/A in GLOB.Banlist.dir)
		GLOB.Banlist.cd = "/base/[A]"
		if (key == GLOB.Banlist["key"] /*|| id == Banlist["id"]*/)
			GLOB.Banlist.cd = "/base"
			GLOB.Banlist.dir.Remove(A)
			continue

	return 1

/proc/GetExp(minutes as num)
	UpdateTime()
	var/exp = minutes - GLOB.CMinutes
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/datum/admins/proc/unbanpanel()
	var/count = 0
	var/dat
	GLOB.Banlist.cd = "/base"
	for (var/A in GLOB.Banlist.dir)
		count++
		GLOB.Banlist.cd = "/base/[A]"
		var/ref		= "[REF(src)]"
		var/key		= GLOB.Banlist["key"]
		var/id		= GLOB.Banlist["id"]
		var/ip		= GLOB.Banlist["ip"]
		var/reason	= GLOB.Banlist["reason"]
		var/by		= GLOB.Banlist["bannedby"]
		var/expiry
		if(GLOB.Banlist["temp"])
			expiry = GetExp(GLOB.Banlist["minutes"])
			if(!expiry)
				expiry = "Removal Pending"
		else
			expiry = "Permaban"

		dat += text("<tr><td><A href='?src=[ref];unbanf=[key][id]'>(U)</A><A href='?src=[ref];unbane=[key][id]'>(E)</A> Key: <B>[key]</B></td><td>ComputerID: <B>[id]</B></td><td>IP: <B>[ip]</B></td><td> [expiry]</td><td>(By: [by])</td><td>(Reason: [reason])</td></tr>")

	dat += "</table>"
	dat = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=unbanp;size=875x400")

//////////////////////////////////// DEBUG ////////////////////////////////////

/proc/CreateBans()

	UpdateTime()

	var/i
	var/last

	for(i=0, i<1001, i++)
		var/a = pick(1,0)
		var/b = pick(1,0)
		if(b)
			GLOB.Banlist.cd = "/base"
			GLOB.Banlist.dir.Add("trash[i]trashid[i]")
			GLOB.Banlist.cd = "/base/trash[i]trashid[i]"
			WRITE_FILE(GLOB.Banlist["key"], "trash[i]")
		else
			GLOB.Banlist.cd = "/base"
			GLOB.Banlist.dir.Add("[last]trashid[i]")
			GLOB.Banlist.cd = "/base/[last]trashid[i]"
			WRITE_FILE(GLOB.Banlist["key"], last)
		WRITE_FILE(GLOB.Banlist["id"], "trashid[i]")
		WRITE_FILE(GLOB.Banlist["reason"], "Trashban[i].")
		WRITE_FILE(GLOB.Banlist["temp"], a)
		WRITE_FILE(GLOB.Banlist["minutes"], GLOB.CMinutes + rand(1,2000))
		WRITE_FILE(GLOB.Banlist["bannedby"], "trashmin")
		last = "trash[i]"

	GLOB.Banlist.cd = "/base"

/proc/ClearAllBans()
	GLOB.Banlist.cd = "/base"
	for (var/A in GLOB.Banlist.dir)
		RemoveBan(A)
