/datum/controller/subsystem/ticker/proc/gather_roundend_feedback()
	var/clients = GLOB.player_list.len
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0

	for(var/mob/M in GLOB.player_list)
		if(ishuman(M))
			if(!M.stat)
				surviving_humans++
				if(M.z == ZLEVEL_CENTCOM)
					escaped_humans++
		if(!M.stat)
			surviving_total++
			if(M.z == ZLEVEL_CENTCOM)
				escaped_total++

		if(isobserver(M))
			ghosts++

	if(clients)
		SSblackbox.record_feedback("nested tally", "round_end_stats", clients, list("clients"))
	if(ghosts)
		SSblackbox.record_feedback("nested tally", "round_end_stats", ghosts, list("ghosts"))
	if(surviving_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_humans, list("survivors", "human"))
	if(surviving_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", surviving_total, list("survivors", "total"))
	if(escaped_humans)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_humans, list("escapees", "human"))
	if(escaped_total)
		SSblackbox.record_feedback("nested tally", "round_end_stats", escaped_total, list("escapees", "total"))

	gather_antag_success_rate()

/datum/controller/subsystem/ticker/proc/gather_antag_success_rate()
	var/list/all_teams = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		var/T = A.get_team()
		if(T)
			all_teams |= T
		if(!A.owner)
			continue
		for(var/datum/objective/O in A.objectives)
			if(O.check_completion())
				SSblackbox.record_feedback("nested tally", "antagonists", 1, list("[A.owner.key]", "[A.type]", "[O.type]" , "SUCCESS"))
			else
				SSblackbox.record_feedback("nested tally", "antagonists", 1, list("[A.owner.key]", "[A.type]", "[O.type]", "FAIL"))
	
	var/gid = 1 //To diffrentiate multiple teams of same type for now. Ideally all of them get names later
	for(var/datum/objective_team/T in all_teams)
		for(var/datum/mind/M in T.members)
			SSblackbox.record_feedback("nested tally", "teams", 1, list("[T.type]", "[gid]", "[M.key]"))
		gid++

/datum/controller/subsystem/ticker/proc/declare_completion()
	set waitfor = FALSE

	to_chat(world, "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>")
	if(LAZYLEN(GLOB.round_end_notifiees))
		send2irc("Notice", "[GLOB.round_end_notifiees.Join(", ")] the round has ended.")

	for(var/client/C in GLOB.clients)
		if(!C.credits)
			C.RollCredits()
		C.playtitlemusic(40)

	display_report()

	gather_roundend_feedback()

	CHECK_TICK

	//Set news report and mode result
	mode.set_round_result()
	
	send2irc("Server", "Round just ended.")
	
	//autodeclares

	if(CONFIG_GET(string/cross_server_address))
		send_news_report()

	CHECK_TICK

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	CHECK_TICK

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	CHECK_TICK

	//Collects persistence features
	if(mode.allow_persistence_save)
		SSpersistence.CollectData()

	//stop collecting feedback during grifftime
	SSblackbox.Seal()

	sleep(50)
	if(mode.station_was_nuked)
		Reboot("Station destroyed by Nuclear Device.", "nuke")
	else
		Reboot("Round ended.", "proper completion")

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	//Gamemode specific things. Should be empty most of the time.
	var/list/mode_special = mode.special_report()
	if(mode_special && length(mode_special) > 0)
		parts += mode_special
		parts += "<hr>"

	//Survivors & Integrity
	parts += survivor_report()
	parts += "<hr>"

	//AI laws
	var/list/law_report = law_report()
	if(law_report && length(law_report) > 0)
		parts += law_report
		parts += "<hr>"

	//Antagonists
	parts += antag_report()
	parts += "<hr>"

	//Medals
	var/list/medal_report = medal_report()
	if(medal_report && length(medal_report) > 0)
		parts += medal_report
		parts += "<hr>"

	//Station Goals
	var/list/goal_report = goal_report()
	if(goal_report && length(goal_report) > 0)
		parts += goal_report

	listclearnulls(parts)

	return parts.Join("<br>")


/datum/controller/subsystem/ticker/proc/survivor_report()
	. = list()
	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/num_survivors = 0
	var/num_escapees = 0
	var/num_shuttle_escapees = 0

	//Player status report
	for(var/i in GLOB.mob_list)
		var/mob/Player = i
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/list/area/shuttle_areas
					if(SSshuttle && SSshuttle.emergency)
						shuttle_areas = SSshuttle.emergency.shuttle_areas
					if(Player.onCentCom() || Player.onSyndieBase())
						num_escapees++
						if(shuttle_areas[get_area(Player)])
							num_shuttle_escapees++

	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)

	. += "[GLOB.TAB]Shift Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B>"
	. += "[GLOB.TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>"
	var/total_players = GLOB.joined_player_list.len
	if(total_players)
		.+= "[GLOB.TAB]Total Population: <B>[total_players]</B>"
		if(station_evacuated)
			. += "<BR>[GLOB.TAB]Evacuation Rate: <B>[num_escapees] ([PERCENT(num_escapees/total_players)]%)</B>"
			. += "[GLOB.TAB](on emergency shuttle): <B>[num_shuttle_escapees] ([PERCENT(num_shuttle_escapees/total_players)]%)</B>"
		. += "[GLOB.TAB]Survival Rate: <B>[num_survivors] ([PERCENT(num_survivors/total_players)]%)</B>"

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C,common_report)
	var/list/report_parts = list()
	
	//You survived header
	var/mob/M = C.mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() || !M.onSyndieBase())
					report_parts += "<font color='blue'><b>You managed to survive, but were marooned on [station_name()]...</b></font>"
				else
					report_parts += "<font color='green'><b>You managed to survive the events on [station_name()] as [M.real_name].</b></font>"
			else
				report_parts += "<font color='green'><b>You managed to survive the events on [station_name()] as [M.real_name].</b></font>"

		else
			report_parts += "<font color='red'><b>You did not survive the events on [station_name()]...</b></font>"

	report_parts += common_report

	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	roundend_report.set_content(report_parts.Join("<br>"))
	roundend_report.stylesheets = list("browserOutput.css") //replace ui styling with chat one
	//TODO Move these to fresh css file so we have a standard of what goes on the report instead of current soup
	
	roundend_report.open(0)

/datum/controller/subsystem/ticker/proc/display_report()
	var/common_report = build_roundend_report()
	for(var/client/C in GLOB.clients)
		show_roundend_report(C,common_report)

/datum/controller/subsystem/ticker/proc/law_report()
	. = list()
	//Silicon laws report
	for (var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/aiPlayer = i
		if(aiPlayer.mind)
			. += "<b>[aiPlayer.name] (Played by: [aiPlayer.mind.key])'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was deactivated"] were:</b>"
			. += aiPlayer.laws.get_law_list(include_zeroth=TRUE)

		. += "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if (aiPlayer.connected_robots.len)
			var/robolist = "<b>[aiPlayer.real_name]'s minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				if(robo.mind)
					robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.mind.key]), ":" (Played by: [robo.mind.key]), "]"
			. += "[robolist]"

	for (var/mob/living/silicon/robot/robo in GLOB.silicon_mobs)
		if (!robo.connected_ai && robo.mind)
			if (robo.stat != DEAD)
				. += "<b>[robo.name] (Played by: [robo.mind.key]) survived as an AI-less borg! Its laws were:</b>"
			else
				. += "<b>[robo.name] (Played by: [robo.mind.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</b>"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				. += robo.laws.get_law_list(include_zeroth=TRUE)

/datum/controller/subsystem/ticker/proc/goal_report()
	. = list()
	for(var/V in mode.station_goals)
		var/datum/station_goal/G = V
		. += G.get_result()

/datum/controller/subsystem/ticker/proc/medal_report()
	. = list()
	if(GLOB.commendations.len)
		. += "<b><font size=3>Medal Commendations:</font></b>"
		for (var/com in GLOB.commendations)
			. += com

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/result = list()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		all_teams |= A.get_team()
		all_antagonists += A

	for(var/datum/objective_team/T in all_teams)
		result += T.roundend_report()
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X

	var/currrent_category
	var/datum/antagonist/previous_category

	sortTim(all_antagonists, /proc/cmp_antag_category)

	for(var/datum/antagonist/A in all_antagonists)
		if(!A.show_in_roundend)
			continue
		if(A.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
			result += A.roundend_report_header()
			currrent_category = A.roundend_category
			previous_category = A
		result += A.roundend_report()
		result += " "//some space between antags
	
	if(all_antagonists.len)
		var/datum/antagonist/last = all_antagonists[all_antagonists.len]
		result += last.roundend_report_footer()

	return result

/proc/cmp_antag_category(datum/antagonist/A,datum/antagonist/B)
	return sorttext(B.roundend_category,A.roundend_category)

/mob/verb/debug_report()
	SSticker.display_report()
