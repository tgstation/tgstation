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
								entry += " - <font color='gray'>Observing</font>"
							else
								entry += " - <font color='black'><b>DEAD</b></font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
				if(is_special_character(C.mob))
					var/antagtext = "Antagonist"
					if(C.mob.mind && C.mob.mind.special_role && lowertext(C.mob.mind.special_role) != "traitor" && lowertext(C.mob.mind.special_role) != "changeling" && lowertext(C.mob.mind.special_role) != "mode")
						antagtext = "[C.mob.mind.special_role]"
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

/*/client/verb/view_title()
	var/text = "[world.status]"
	src << browse(text,"window=worldnametest;size=300x300")*/