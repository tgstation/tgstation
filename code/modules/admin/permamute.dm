var/savefile/Mute

/proc/load_mute()
	Mute = new("data/mute.bdb")

	if (!Mute.dir.Find("base"))
		Mute.dir.Add("base")
		Mute.cd = "/base"
	else if (Mute.dir.Find("base"))
		Mute.cd = "/base"

/proc/oocmuted(ckey)
	Mute.cd = "/base"
	if(Mute.dir.Find("ooc[ckey]"))
		return 1
	return 0

/proc/ahmuted(ckey)
	Mute.cd = "/base"
	if(Mute.dir.Find("hlp[ckey]"))
		return 1
	return 0

/proc/addmute(ckey, bannedby, chat)
	Mute.cd = "/base"

	if (chat == "OOC")
		if ( Mute.dir.Find("ooc[ckey]") )
			usr << text("<span class='danger'>Fucktard already muted from OOC.</span>")
			return 0
		else
			Mute.dir.Add("ooc[ckey]")
			Mute.cd = "/base/ooc[ckey]"
			Mute["key"] << ckey
//			Mute["reason"] << reason
			Mute["bannedby"] << bannedby
			Mute["chat"] << chat
	else
		if ( Mute.dir.Find("hlp[ckey]") )
			usr << text("<span class='danger'>Fucktard already muted from AH.</span>")
			return 0
		else
			Mute.dir.Add("hlp[ckey]")
			Mute.cd = "/base/hlp[ckey]"
			Mute["key"] << ckey
//			Mute["reason"] << reason
			Mute["bannedby"] << bannedby
			Mute["chat"] << chat
	log_admin("[key_name(usr)] permamuted [ckey] from [chat]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has permamuted [ckey] from [chat].</span>")
	return 1

/proc/remove_mute(banfolder)
	var/key

	Mute.cd = "/base/[banfolder]"
	Mute["key"] >> key
	Mute.cd = "/base"

	var/chat = "OOC"
	if (copytext(banfolder,1,4) == "hlp")
		chat = "AH"

	if (!Mute.dir.Remove(banfolder))	return 0

	log_admin("[key_name(usr)] unmuted [key] from [chat]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] unpermamuted [key] from [chat].</span>")
	return 1

/datum/admins/proc/mutepanel()
	set category = "Admin"
	set name = "Mute Panel"
	set desc = "List of permamuted tards"
	if(!check_rights(R_BAN)) return

	var/count = 0
	var/dat
	//var/dat = "<HR><B>Unban Player:</B> \blue(U) = Unban , (E) = Edit Ban\green (Total<HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >"
	Mute.cd = "/base"
	var/prfx = "ooc"
	for (var/A in Mute.dir)
		count++
		if(copytext(A,1,4) == "hlp")
			prfx = "hlp"
		else
			prfx = "ooc"
		Mute.cd = "/base/[A]"
		dat += text("<tr><td><A href='?_src_=holder;unmutef=[prfx][Mute["key"]]'>(U)</A> Key: <B>[Mute["key"]] </B></td><td>Chat: <b>[Mute["chat"]]</b></td><td>(By: [Mute["bannedby"]])</td></tr>")
		//<td>(Reason: [Mute["reason"]])</td>

	dat += "</table>"
	dat = "<HR><B>Mutes:</B> <FONT COLOR=blue>(U) = Unban |</FONT> <FONT COLOR=green>[count] mutes</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=unmutep;size=875x400")
