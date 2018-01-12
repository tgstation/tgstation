//I wish we had interfaces sigh, and i'm not sure giving team and antag common root is a better solution here

//Name shown on antag list
/datum/antagonist/proc/antag_listing_name(datum/mind/owner)
	if(!owner)
		return "Unassigned"
	if(owner.current)
		return "<a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(owner.current)]>[owner.current.real_name]</a>"
	else
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(traitor)]'>[owner.name]</a>"

//Whatever interesting things happened to the antag admins should know about
//Include additional information about antag in this part
/datum/antagonist/proc/antag_listing_status()
	if(!owner)
		return "(Unassigned)"
	
	if(!owner.current)
		return "<font color=red>(Body destroyed)</font>"
	else
		if(owner.current.stat == DEAD)
			return "<font color=red>(DEAD)</font>"
		else if(!owner.current.client)
			return "(No client)"

//Builds the common FLW PM TP commands part
//Probably not going to be overwritten by anything but you never know
/datum/antagonist/proc/antag_listing_commands()
	if(!owner)
		return
	var/list/parts = list()
	parts += "<a href='?priv_msg=[owner.key]'>PM</a>"
	if(owner.current) //There's body to follow
		parts += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(owner.current)]'>FLW</a>"
	parts += "<a href='?_src_=holder;[HrefToken()];traitor=[REF(owner)]'>TP</a>"
	return parts.Join(" ")

//Builds table row for the antag
// Jim (Status) FLW PM TP
/datum/antagonist/proc/antag_listing_entry()
	var/list/parts = list()
	parts += antag_listing_name()
	parts += antag_listing_status()
	parts += antag_listing_commands()
	return "<tr><td>[parts.Join("</td><td>")]</td></tr>"


/datum/team/proc/get_team_antags(antag_type,specific = FALSE)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(A.get_team() == src && (!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type))
			. += A

//Builds section for the team
/datum/team/proc/antag_listing_entry()
	//NukeOps:
	// Jim (Status) FLW PM TP
	// Joe (Status) FLW PM TP
	//Disk:
	// Deep Space FLW
	var/list/parts = list()
	//TODO Should probably be a span on top instead th
	parts += "<table cellspacing=5><tr><th>[antag_listing_name()]</th><th></th><th></th></tr>"
	for(var/datum/antagonist/A in get_team_antags())
		parts += A.antag_listing_entry()
	parts += "</table>"
	parts += antag_listing_footer()
	return parts.Join()

/datum/team/proc/antag_listing_name()
	return name

/datum/team/proc/antag_listing_footer()
	return


//Moves them to the top of the list if TRUE
/datum/antagonist/proc/is_gamemode_hero()
	return FALSE

/datum/team/proc/is_gamemode_hero()
	return FALSE

/proc/buildit()
	var/list/sections = list()
	var/list/priority_sections = list()

	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_teams |= A.get_team()
		all_antagonists += A

	for(var/datum/team/T in all_teams)
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		if(T.is_gamemode_hero())
			sections += T.antag_listing_entry()
		else
			priority_sections += T.antag_listing_entry()

	var/currrent_category
	var/datum/antagonist/previous_category

	sortTim(all_antagonists, /proc/cmp_antag_category)

	var/current_category
	var/list/current_section = list()
	for(var/i in 1 to all_antagonists.len)
		var/datum/antagonist/current_antag = all_antagonists[i]
		var/datum/antagonist/next_antag 
		if(i < all_antagonists.len - 1)
			next_antag = all_antagonists[i+1]
		if(!current_category)
			current_category = current_antag.roundend_category
			current_section += "<table cellspacing=5><tr><td><B>[current_category]</B></td><td></td></tr>"
		current_section += current_antag.antag_listing_entry() // Name - (Traitor) - FLW | PM | TP

		if(!next_antag || next_antag.roundend_category != current_antag.roundend_category) //End of section
			current_section += "</table>"
			if(hero)
				priority_sections += current_section.Join()
			else
				sections += current_section.Join()
			current_section.Cut()
			current_category = null

	return priority_sections.Join("<br>") + sections.Join("<br>")

/datum/admins/proc/check_antagonists()
	if (SSticker.HasRoundStarted())
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
		if(SSticker.mode.replacementmode)
			dat += "Former Game Mode: <B>[SSticker.mode.name]</B><BR>"
			dat += "Replacement Game Mode: <B>[SSticker.mode.replacementmode.name]</B><BR>"
		else
			dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B><BR>"
		dat += "<B>Emergency shuttle</B><BR>"
		if(EMERGENCY_IDLE_OR_RECALLED)
			dat += "<a href='?_src_=holder;[HrefToken()];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = SSshuttle.emergency.timeLeft()
			if(SSshuttle.emergency.mode == SHUTTLE_CALL)
				dat += "ETA: <a href='?_src_=holder;[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
				dat += "<a href='?_src_=holder;[HrefToken()];call_shuttle=2'>Send Back</a><br>"
			else
				dat += "ETA: <a href='?_src_=holder;[HrefToken()];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
		dat += "<B>Continuous Round Status</B><BR>"
		dat += "<a href='?_src_=holder;[HrefToken()];toggle_continuous=1'>[CONFIG_GET(keyed_flag_list/continuous)[SSticker.mode.config_tag] ? "Continue if antagonists die" : "End on antagonist death"]</a>"
		if(CONFIG_GET(keyed_flag_list/continuous)[SSticker.mode.config_tag])
			dat += ", <a href='?_src_=holder;[HrefToken()];toggle_midround_antag=1'>[CONFIG_GET(keyed_flag_list/midround_antag)[SSticker.mode.config_tag] ? "creating replacement antagonists" : "not creating new antagonists"]</a><BR>"
		else
			dat += "<BR>"
		if(CONFIG_GET(keyed_flag_list/midround_antag)[SSticker.mode.config_tag])
			dat += "Time limit: <a href='?_src_=holder;[HrefToken()];alter_midround_time_limit=1'>[CONFIG_GET(number/midround_antag_time_check)] minutes into round</a><BR>"
			dat += "Living crew limit: <a href='?_src_=holder;[HrefToken()];alter_midround_life_limit=1'>[CONFIG_GET(number/midround_antag_life_check) * 100]% of crew alive</a><BR>"
			dat += "If limits past: <a href='?_src_=holder;[HrefToken()];toggle_noncontinuous_behavior=1'>[SSticker.mode.round_ends_with_antag_death ? "End The Round" : "Continue As Extended"]</a><BR>"
		dat += "<a href='?_src_=holder;[HrefToken()];end_round=[REF(usr)]'>End Round Now</a><br>"
		dat += "<a href='?_src_=holder;[HrefToken()];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a>"
		var/connected_players = GLOB.clients.len
		var/lobby_players = 0
		var/observers = 0
		var/observers_connected = 0
		var/living_players = 0
		var/living_players_connected = 0
		var/living_players_antagonist = 0
		var/brains = 0
		var/other_players = 0
		var/living_skipped = 0
		var/drones = 0
		for(var/mob/M in GLOB.mob_list)
			if(M.ckey)
				if(isnewplayer(M))
					lobby_players++
					continue
				else if(M.stat != DEAD && M.mind && !isbrain(M))
					if(isdrone(M))
						drones++
						continue
					if(is_centcom_level(M.z))
						living_skipped++
						continue
					living_players++
					if(M.mind.special_role)
						living_players_antagonist++
					if(M.client)
						living_players_connected++
				else if(M.stat == DEAD || isobserver(M))
					observers++
					if(M.client)
						observers_connected++
				else if(isbrain(M))
					brains++
				else
					other_players++
		dat += "<BR><b><font color='blue' size='3'>Players:|[connected_players - lobby_players] ingame|[connected_players] connected|[lobby_players] lobby|</font></b>"
		dat += "<BR><b><font color='green'>Living Players:|[living_players_connected] active|[living_players - living_players_connected] disconnected|[living_players_antagonist] antagonists|</font></b>"
		dat += "<BR><b><font color='#bf42f4'>SKIPPED \[On centcom Z-level\]: [living_skipped] living players|[drones] living drones|</font></b>"
		dat += "<BR><b><font color='red'>Dead/Observing players:|[observers_connected] active|[observers - observers_connected] disconnected|[brains] brains|</font></b>"
		if(other_players)
			dat += "<BR><span class='userdanger'>[other_players] players in invalid state or the statistics code is bugged!</span>"
		dat += "<BR>"

		var/list/nukeops = get_antagonists(/datum/antagonist/nukeop)
		if(nukeops.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in nukeops)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
				else
					dat += "<tr><td><i><a href='?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a> Nuclear Operative Body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!isturf(disk_loc))
					if(ismob(disk_loc))
						var/mob/M = disk_loc
						dat += "carried by <a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a> "
					if(isobj(disk_loc))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		var/list/revs = get_antagonists(/datum/antagonist/rev)
		if(revs.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in get_antagonists(/datum/antagonist/rev/head))
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a><i>Head Revolutionary body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
			for(var/datum/mind/N in get_antagonists(/datum/antagonist/rev,TRUE))
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in SSjob.get_living_heads())
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					var/turf/mob_loc = get_turf(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a><i>Head body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
			dat += "</table>"


		var/list/lings = get_antagonists(/datum/antagonist/changeling)
		if(lings.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Changelings</B></td><td></td><td></td></tr>"
			for(var/datum/mind/changeling in lings)
				var/datum/antagonist/changeling/lingantag = changeling.has_antag_datum(/datum/antagonist/changeling)
				var/mob/M = changeling.current
				if(M)
					dat += "<tr><td>[lingantag.changelingID]([lingantag.name]) as <a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(changeling)]'>[changeling.name]([changeling.key])</a><i>Changeling body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[changeling.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.wizards.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Wizards</B></td><td></td><td></td></tr>"
			for(var/datum/mind/wizard in SSticker.mode.wizards)
				var/mob/M = wizard.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(wizard)]'>[wizard.name]([wizard.key])</a><i>Wizard body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[wizard.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.apprentices.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Apprentice</B></td><td></td><td></td></tr>"
			for(var/datum/mind/apprentice in SSticker.mode.apprentices)
				var/mob/M = apprentice.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(apprentice)]'>[apprentice.name]([apprentice.key])</a><i>Apprentice body destroyed!!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[apprentice.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.cult.len)
			dat += "<br><table cellspacing=5><tr><td><B>Cultists</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.cult)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[N.has_antag_datum(ANTAG_DATUM_CULT_MASTER) ? "<i><font color=red> \[Master\]</font></i>" : ""][M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
			dat += "</table>"

		if(SSticker.mode.servants_of_ratvar.len)
			dat += "<br><table cellspacing=5><tr><td><B>Servants of Ratvar</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.servants_of_ratvar)
				var/mob/M = N.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(ghost)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
			dat += "</table>"

		if(SSticker.mode.traitors.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/traitor in SSticker.mode.traitors)
				var/mob/M = traitor.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(traitor)]'>[traitor.name]([traitor.key])</a><i>Traitor body destroyed!</i></td>"
					dat += "<td><A href='?priv_msg=[traitor.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.brother_teams.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Brothers</B></td><td></td><td></td></tr>"
			for(var/datum/team/brother_team/team in SSticker.mode.brother_teams)
				for(var/datum/mind/brother in team.members)
					var/mob/M = brother.current
					if(M)
						dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
						dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
						dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
						dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
					else
						dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(brother)]'>[brother.name]([brother.key])</a><i>Brother body destroyed!</i></td>"
						dat += "<td><A href='?priv_msg=[brother.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.abductors.len)
			dat += "<br><table cellspacing=5><tr><td><B>Abductors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/abductor in SSticker.mode.abductors)
				var/mob/M = abductor.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(abductor)]'>[abductor.name]([abductor.key])</a><i>Abductor body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[abductor.key]'>PM</A></td>"
			dat += "</table>"
			dat += "<br><table cellspacing=5><tr><td><B>Abductees</B></td><td></td><td></td></tr>"
			for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
				for(var/datum/mind/abductee in E.abductee_minds)
					var/mob/M = abductee.current
					if(M)
						dat += "<tr><td><a href='?_src_=holder[HrefToken()];;adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
						dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
						dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
						dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
					else
						dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(abductee)]'>[abductee.name]([abductee.key])</a><i>Abductee body destroyed!</i></td>"
						dat += "<td><A href='?priv_msg=[abductee.key]'>PM</A></td></tr>"
			dat += "</table>"

		if(SSticker.mode.devils.len)
			dat += "<br><table cellspacing=5><tr><td><B>devils</B></td><td></td><td></td></tr>"
			for(var/X in SSticker.mode.devils)
				var/datum/mind/devil = X
				var/mob/M = devil.current
				var/datum/antagonist/devil/devilinfo = devil.has_antag_datum(ANTAG_DATUM_DEVIL)
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name] : [devilinfo.truename]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];admincheckdevilinfo=[REF(M)]'>Show all devil info</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(devil)]'>[devil.name] :  [devilinfo.truename] ([devil.key])</a><i>devil body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[devil.key]'>PM</A></td>"
			dat += "</table>"

		if(SSticker.mode.sintouched.len)
			dat += "<br><table cellspacing=5><tr><td><B>sintouched</B></td><td></td><td></td></tr>"
			for(var/X in SSticker.mode.sintouched)
				var/datum/mind/sintouched = X
				var/mob/M = sintouched.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A HREF='?_src_=holder;[HrefToken()];traitor=[REF(M)]'>Show Objective</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(sintouched)]'>[sintouched.name]([sintouched.key])</a><i>sintouched body destroyed!</i></td></tr>"
					dat += "<td><A href='?priv_msg=[sintouched.key]'>PM</A></td>"
			dat += "</table>"

		var/list/blob_minds = list()
		for(var/mob/camera/blob/B in GLOB.mob_list)
			blob_minds |= B.mind
			if(blob_minds.len)
				dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			for(var/datum/mind/blob in blob_minds)
				var/mob/camera/blob/M = blob.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
					dat += "<tr><td><i>Progress: [M.blobs_legit.len]/[M.blobwincount]</i></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(blob)]'>[blob.name]([blob.key])</a><i>Blob not found!</i></td>"
					dat += "<td><A href='?priv_msg=[blob.key]'>PM</A></td></tr>"
			dat += "</table>"


		var/list/pirates = get_antagonists(/datum/antagonist/pirate)
		if(pirates.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Pirates</B></td><td></td></tr>"
			for(var/datum/mind/N in pirates)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=\ref[N]'>[N.name]([N.key])</a><i>No body.</i></td>"
					dat += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=\ref[M]'>FLW</a></td></tr>"
			dat += "</table>"

		if(istype(SSticker.mode, /datum/game_mode/monkey))
			var/datum/game_mode/monkey/mode = SSticker.mode
			dat += "<br><table cellspacing=5><tr><td><B>Monkey</B></td><td></td><td></td></tr>"

			for(var/datum/mind/eek in mode.ape_infectees)
				var/mob/M = eek.current
				if(M)
					dat += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
					dat += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td></tr>"
				else
					dat += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(eek)]'>[eek.name]([eek.key])</a><i>Monkey not found!</i></td>"
					dat += "<td><A href='?priv_msg=[eek.key]'>PM</A></td></tr>"
			dat += "</table>"


		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=420x500")
	else
		alert("The game hasn't started yet!")