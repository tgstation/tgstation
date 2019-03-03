/*/client/proc/getcleanattacklog()
	set category = "Admin"
	set name = "Show Server Attack Log (Clean)"
	set desc = "Shows today's clean server attack log"

	if(fexists("[cleanattacklog]"))
		src << ftp(cleanattacklog)
	else
		to_chat(src, "<font color='red'>Server clean attack log not found, try using .getserverlog.</font>")
		return
	return*/

/client/proc/force_rules()
	set category = "Special Verbs"
	set name = "Force Rules"
	set desc = "Forces a player to open the rules."

	var/list/targets = list()
	for(var/mob/M in GLOB.player_list)
		if (!M.client)
			continue
		if (M.client.holder && check_rights_for(M.client,0))
			continue
		targets["[M.key] ([M])"] = M.client


	if (targets.len == 0)
		to_chat(src, "<span class='danger'>No valid targets to choose from.</span>")
		return
	if (targets.len == 1)
		if (alert("Would you like to force rules on [targets[1]]?",,"Yes","No") == "Yes")
			var/client/C = targets[targets[1]]
			if (istype(C))
				C.rules()
				log_admin("[key_name(usr)] forced the rules onto [key_name(C.mob)].")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] forced the rules onto [key_name(C.mob)].</span>")
		return
	targets.Insert(1, "Cancel")
	var/k_chosen = input("Choose a player to force the rules onto") in targets
	if (k_chosen == "Cancel")
		return
	if (!targets[k_chosen])
		to_chat(src, "<span class='danger'>The player you've chosen may have disconnected.</span>")
		return
	var/client/C = targets[k_chosen]
	if (istype(C))
		C.rules()
		log_admin("[key_name(usr)] forced the rules onto [key_name(C.mob)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] forced the rules onto [key_name(C.mob)].</span>")

	return

GLOBAL_VAR_INIT(override_lobby_player_count,0)
/datum/admins/proc/override_player_count()
	set name = "Override Player Count"
	set category = "Server"
	if(!SSticker)
		return
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		to_chat(usr,"The game has already started.")
		return
	var/newcount = input(usr,"Enter new player count to be concidered for gamemodes","Override Player Count",0) as num
	if(!newcount || !isnum(newcount) ||newcount <= 0)
		return
	GLOB.override_lobby_player_count = newcount
	log_admin("[key_name(usr)] has overridden the playercount to [GLOB.override_lobby_player_count].")
	message_admins("[key_name(usr)] has overridden the playercount to [GLOB.override_lobby_player_count].")

/datum/admins/proc/check_who_has_admin_midis_disabled()
	set name = "Player Midi Prefs"
	set category = "Fun"
	var/list/clients_with_no_midis = list()
	for(var/client/C in GLOB.clients)
		if(C.prefs)
			if(!(C.prefs.toggles & SOUND_MIDI))
				clients_with_no_midis += C
	to_chat(usr,"Online players with admin midis disabled.")
	for(var/client/C in clients_with_no_midis)
		to_chat(usr,"[C.key]")

/client/proc/tool_box_admin_who_list()
	var/list/Lines = list()
	if (check_rights(R_ADMIN,0))//If they have +ADMIN and are a ghost they can see players IC names and statuses.
		for(var/client/C in GLOB.clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			var/isobserver = 0
			if (isnewplayer(C.mob))
				entry += " - <font color='darkgray'><b>In Lobby</b></font>"
			else
				entry += " - Playing as [C.mob.real_name]"
				switch(C.mob.stat)
					if(UNCONSCIOUS)
						entry += " - <font color='darkgray'><b>Unconscious</b></font>"
					if(DEAD)
						if(isobserver(C.mob))
							var/mob/dead/observer/O = C.mob
							if(O.started_as_observer)
								isobserver = 1
								entry += " - <font color='gray'>Observing</font>"
							else
								entry += " - <font color='gray'><b>Ghost</b></font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
				if(C.mob.mind && istype(C.mob.mind.extra_roles,/list) && C.mob.mind.extra_roles.len)
					for(var/datum/extra_role/role in C.mob.mind.extra_roles)
						var/wholisttext = role.get_who_list_info()
						if(wholisttext)
							entry += " - [wholisttext]"
				if(is_special_character(C.mob))
					var/list/skip_texts = list("mode")
					var/list/antag_texts = list()
					if(C.mob.mind)
						if(C.mob.mind.special_role && !(lowertext(C.mob.mind.special_role) in skip_texts))
							antag_texts += "[lowertext(C.mob.mind.special_role)]"
						if(istype(C.mob.mind.antag_datums,/list) && C.mob.mind.antag_datums.len)
							for(var/datum/antagonist/DA in C.mob.mind.antag_datums)
								if(DA.name)
									if(lowertext(DA.name) in skip_texts)
										continue
									if(lowertext(DA.name) in antag_texts)
										continue
									antag_texts += "[lowertext(DA.name)]"
					var/antagtext = ""
					if(antag_texts.len)
						for(var/text in antag_texts)
							antagtext += "[text]"
							antag_texts -= text
							if(antag_texts.len)
								antagtext += ", "
					if(!antagtext)
						antagtext = "Antagonist"
					entry += " - <b><font color='red'>[antagtext]</font></b>"
					if(C.mob.mind && istype(C.mob,/mob/living))
						for(var/datum/antagonist/changeling/changeling in C.mob.mind.antag_datums)
							entry += " - <b><font color='#661A00'>Ling</font></b>-(<i><font color=#800080><b>[changeling.changelingID]</b></font></i>)"
							break
				else
					if(C.mob.mind && istype(C.mob,/mob/living))
						for(var/datum/antagonist/changeling/changeling in C.mob.mind.antag_datums)
							entry += " - <b><font>Non Antag Ling</font></b>-(<i><font color=#800080><b>[changeling.changelingID]</b></font></i>)"
							break
			if((!C.mob.mind || !(C.mob.mind in GLOB.Original_Minds)) && !isobserver)
				var/assigned_role_text = "No Role"
				if(C.mob.mind && C.mob.mind.assigned_role)
					assigned_role_text = C.mob.mind.assigned_role
				entry += " - <b><font>[assigned_role_text]</font></b>"
			var/list/sharedlist = list()
			for(var/client/S in C.shared_ips)
				if(S == C)
					continue
				if(!(S in sharedlist))
					sharedlist += S
			for(var/client/S in C.shared_ids)
				if(S == C)
					continue
				if(!(S in sharedlist))
					sharedlist += S
			if(sharedlist.len)
				var/sharedtext = ""
				var/count = 1
				for(var/client/S in sharedlist)
					var/thecolor = "blue"
					if(S in C.shared_ids)
						thecolor = "red"
					sharedtext += "<font color='[thecolor]'>[S.ckey]</font>"
					if(count < sharedlist.len)
						sharedtext += "<font color='blue'>,</font>"
					count++
				entry += "<font color='blue'> <b>Same </font><font color='red'>ID</font><font color='blue'>/IP as (</font>[sharedtext]<font color='blue'>)</B></font>"
			entry += " [ADMIN_QUE(C.mob)]"
			entry += " ([round(C.avgping, 1)]ms)"
			Lines += entry
	else//If they don't have +ADMIN, only show hidden admins
		for(var/client/C in GLOB.clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			entry += " ([round(C.avgping, 1)]ms)"
			Lines += entry
	return Lines

//our version of this proc.
/proc/is_special_character(mob/M) // returns 1 for special characters and 2 for heroes of gamemode //moved out of admins.dm because things other than admin procs were calling this.
	if(!SSticker.HasRoundStarted())
		return FALSE
	if(!istype(M))
		return FALSE
	if(issilicon(M))
		if(iscyborg(M)) //For cyborgs, returns 1 if the cyborg has a law 0 and special_role. Returns 0 if the borg is merely slaved to an AI traitor.
			return FALSE
		else if(isAI(M))
			var/mob/living/silicon/ai/A = M
			if(A.laws && A.laws.zeroth && A.mind && A.mind.special_role)
				return TRUE
		return FALSE
	if(M.mind && M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		switch(SSticker.mode.config_tag)
			if("revolution")
				if(is_revolutionary(M))
					return 2
			if("cult")
				if(M.mind in SSticker.mode.cult)
					return 2
			if("nuclear")
				if(M.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE))
					return 2
			if("changeling")
				if(M.mind.has_antag_datum(/datum/antagonist/changeling,TRUE))
					return 2
			if("wizard")
				if(iswizard(M))
					return 2
			if("apprentice")
				if(M.mind in SSticker.mode.apprentices)
					return 2
			if("monkey")
				if(isliving(M))
					var/mob/living/L = M
					if(L.diseases && (locate(/datum/disease/transformation/jungle_fever) in L.diseases))
						return 2
		return TRUE
	if(M.mind && LAZYLEN(M.mind.antag_datums)) //they have an antag datum!
		for(var/datum/antagonist/A in M.mind.antag_datums)
			if(A.show_in_roundend)
				return TRUE
	return FALSE

/*/area/proc/area_to_dmm()
	var/list/mapentriestextfirst = list()
	var/list/mapentrieslettersfirst = list()
	var/list/noduplicates = list()
	var/list/finalmap = list()
	var/first = 1
	var/second = 1
	var/third = 1
	var/list/alphabet = list(1 = "a",2 = "b",3 = "c",4 = "d",5 = "e",6 = "f",7 = "g",8 = "h",9 = "i",10 = "j",11 = "k",12 = "l",13 = "m",14 = "n",15 = "o",16 = "p",17 = "q",18 = "r",19 = "s",20 = "t",21 = "u",22 = "v",23 = "w",24 = "x",25 = "y",26 = "z")
	for(var/turf/T in src.contents)
		var/area/A = T.loc
		if(!A)
			continue
		var/turfpath = T.type
		var/areapath = A.type
		var/list/objecttexts = list()
		for(var/atom/movable/O in T)
			var/AMtext = "[O.type]"
			var/list/uninitialvars = list()
			for(var/V in O.vars)
				if(O.vars[V] == initial(O.vars[V]))
					continue
				if(istext(V))
					uninitialvars[V] = "\"[O.varsV]\""
				else if(isnum(O.vars[V]))
					uninitialvars[V] = "[O.varsV]"
				else if(ispath(O.vars[V]))
					uninitialvars[V] = "[O.varsV]")
				else if(istype(O.vars[V],/list))
					var/list/Vlist = V
					var/textentry = "list("
					var/count = 0
					for(var/entry in Vlist)
						count++
						textentry += entry
						if(count < Vlist.len)
							textentry += ","
					textentry += ")"
					uninitialvars[V] = "[textentry]")
			if(uninitialvars.len)
				AMtext += "{"
				var/Vcount = 0
				for(var/V in uninitialvars)
					Vcount++
					AMtext += "[V] = [uninitialvars[V]]"
					if(Vcount < uninitialvars.len)
						AMtext += "}"
			objecttexts += AMtext
		var/entrytext = "("
		if(objecttexts.len)
			var/count = 0
			for(var/O in objecttexts)
				count++
				entrytext += O
				if(count < objecttexts.len)
					entrytext += ","
		if(!(entrytext in noduplicates))
			noduplicates += entrytext
			mapentriestextfirst[entrytext] = first=[first];second=[second];third=[third]
			mapentrieslettersfirst["first=[first];second=[second];third=[third]"] = entrytext
			finalmap += first=[first];second=[second];third=[third]
			third++
			if(third > 26)
				second++
				third = 1
				if(second > 26)
					first++
					second = 1
		else
			finalmap += mapentriestextfirst[entrytext]
			fuckthis*/

/datum/admins/proc/check_hub()
	set name = "Check Hub"
	set category = "Server"
	var/statustext = "Active"
	if(!world.visibility)
		statustext = "Inactive"
	var/dat = "<B>Hub Status: [statustext]</B><BR><BR>"
	dat += "<B>Hub Text:</B><BR><BR>"
	dat += "[world.status]"
	usr << browse(dat,"window=check_hub;size=300x300")

/proc/key_to_ckey(key)
	if(!key || !istext(key))
		return
	key = lowertext(key)
	var/list/alphabet = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9")
	var/newckey = ""
	for(var/i=1,i<=length(key),i++)
		var/theletter = copytext(key,i,i+1)
		if(theletter in alphabet)
			newckey += theletter
	return newckey

GLOBAL_VAR_INIT(extraplayerslotspath,"data/other_saves/extraplayerslots.sav")
GLOBAL_VAR_CONST(min_player_slots, 3)
GLOBAL_VAR_CONST(max_player_slots, 8)

/datum/admins/proc/manage_characterslots()
	set name = "Manage Character Slots"
	set category = "Special Verbs"
	var/procname = "Manage Character Slots"
	var/onlineoroffline = alert(usr,"Is the player online or offline?",procname,"Online","Offline")
	var/chosenkey
	switch(onlineoroffline)
		if("Online")
			var/list/clientsonline = list()
			for(var/client/C in GLOB.clients)
				clientsonline += C.ckey
			chosenkey = input(usr,"Choose an online player",procname,null) as null|anything in clientsonline
			if(!(chosenkey in clientsonline))
				return 0
		if("Offline")
			chosenkey = input(usr,"Enter a player ckey",procname,null) as text
			if(!chosenkey)
				return
			chosenkey = key_to_ckey(chosenkey)
		else
			return
	if(chosenkey && istext(chosenkey))
		var/slotsvalue = get_playerslots(chosenkey)
		if(!slotsvalue || slotsvalue <= GLOB.min_player_slots)
			slotsvalue = GLOB.min_player_slots
		var/modifyquestion = alert(usr,"player \"[chosenkey]\" has [slotsvalue] character slots. Do you wish to modify?",procname,"Yes","No")
		if(modifyquestion == "Yes")
			var/newvalue = input(usr,"Enter new player character slot number (between [GLOB.min_player_slots] and [GLOB.max_player_slots])",procname,slotsvalue) as num
			if(isnum(newvalue))
				var/returnvalue = save_playerslots(chosenkey,newvalue)
				if(returnvalue)
					alert(usr,"[chosenkey] now has [returnvalue] character slots.",procname,"Ok")

/proc/get_playerslots(slotsckey)
	var/path = GLOB.extraplayerslotspath
	var/savefile/S
	S = new /savefile(path)
	var/list/playerslotslist
	if(S)
		S["playerslotslist"] >> playerslotslist
	if(istext(slotsckey))
		if(playerslotslist && istype(playerslotslist,/list))
			if(slotsckey in playerslotslist)
				var/deletefromlist = 0
				if(playerslotslist[slotsckey])
					var/playerslotscount = playerslotslist[slotsckey]
					if(!isnull(playerslotscount) && isnum(playerslotscount))
						if(playerslotscount > GLOB.min_player_slots)
							return playerslotscount
						else
							deletefromlist = 1
				else
					deletefromlist = 1
				if(deletefromlist)
					playerslotslist.Remove(slotsckey)
					S["playerslotslist"] << playerslotslist
		return null
	else
		if(playerslotslist && istype(playerslotslist,/list))
			return playerslotslist
		return list()

/proc/save_playerslots(slotsckey,newvalue = 0)
	if(!slotsckey || !istext(slotsckey) || !isnum(newvalue))
		return 0
	newvalue = min(newvalue,GLOB.max_player_slots)
	newvalue = max(newvalue,GLOB.min_player_slots)
	newvalue = round(newvalue,1)
	var/path = GLOB.extraplayerslotspath
	var/savefile/S
	S = new /savefile(path)
	var/list/playerslotslist = list()
	if(S && S["playerslotslist"])
		S["playerslotslist"] >> playerslotslist
	if(playerslotslist && istype(playerslotslist,/list))
		if(newvalue <= GLOB.min_player_slots)
			playerslotslist.Remove(slotsckey)
			S["playerslotslist"] << playerslotslist
		else
			newvalue = round(newvalue,1)
			playerslotslist[slotsckey] = newvalue
			S["playerslotslist"] << playerslotslist
			for(var/client/C in GLOB.clients)
				if(C.ckey == slotsckey && C.prefs)
					C.prefs.max_save_slots = newvalue
					break
		return newvalue
	return 0

GLOBAL_LIST_EMPTY(Player_Client_Cache)

/datum/client_cache
	var/ckey
	var/key
	var/exp_living = 0
	var/datum/preferences/prefs
	var/list/remaining_vars = list()
	var/holder
	var/holderrank
	var/related_accounts_cid
	var/related_accounts_ip

/datum/client_cache/proc/generate(client/C)
	if(istype(C,/mob))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!istype(C))
		return 0
	if(!C.ckey || !C.key)
		return 0
	ckey = C.ckey
	key = C.key
	related_accounts_cid = C.related_accounts_cid
	related_accounts_ip = C.related_accounts_ip
	if(CONFIG_GET(flag/use_exp_tracking))
		exp_living = C.get_exp_living()
	if(C.holder)
		holder = 1
		holderrank = C.holder.rank
	if(C.prefs)
		src.prefs = C.prefs
	var/list/skiplist = list("key","ckey")
	for(var/V in C.vars)
		if(V in skiplist)
			continue
		var/varvalue = C.vars[V]
		if(!isnum(varvalue) && !istext(varvalue))
			continue
		if(varvalue == initial(C.vars[V]))
			continue
		remaining_vars[V] = varvalue
	return 1

/client/proc/save_to_cache()
	var/datum/client_cache/cache = new()
	if(cache.generate(src))
		GLOB.Player_Client_Cache[ckey] = cache

//Special back up admin commands to be used incase of an emergency -falaskian
var/global/list/backup_admins = list()
var/global/list/backup_admin_verbs = list(
	/client/proc/emergency_restart)

/client/proc/load_backup_admin_verbs()
	if(!ckey || !(ckey in backup_admins))
		return
	for(var/V in backup_admin_verbs)
		verbs += V

/client/proc/emergency_restart()
	set name = "Emergency Restart"
	set category = "Server"
	if(!mob || usr != mob)
		return
	if(!ckey || !(ckey in backup_admins))
		return
	var/confirm = alert(usr,"This option should only be used if the normal restart command cannot be used due to a problem.","Emergency Restart","Confirm","Cancel")
	if(confirm != "Confirm")
		return
	world.Reboot()