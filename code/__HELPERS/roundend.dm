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
		var/list/antag_info = list()
		antag_info["ckey"] = A.owner.key
		antag_info["antagonist_type"] = A.type
		antag_info["antagonist_name"] = A.name //For auto and custom roles
		antag_info["objectives"] = list()
		var/T = A.get_team()
		if(T)
			all_teams |= T
		if(!A.owner)
			continue
		if(A.objectives.len)
			for(var/datum/objective/O in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"
				antag_info["objectives"] += list(list("objective_type"=O.type,"text"=O.explanation_text,"result"=result))
		SSblackbox.record_feedback("associative", "antagonists", 1, antag_info)
	
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
	
	if(CONFIG_GET(string/cross_server_address))
		send_news_report()

	CHECK_TICK

	//These need update to actually reflect the real antagonists
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
	. += "[GLOB.TAB]Station Integrity: <B>[mode.station_was_nuked ? "<span class='redtext'>Destroyed</span>" : "[station_integrity]%"]</B>"
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
					report_parts += "<span class='marooned'>You managed to survive, but were marooned on [station_name()]...</span>"
				else
					report_parts += "<span class='greentext'>You managed to survive the events on [station_name()] as [M.real_name].</span>"
			else
				report_parts += "<span class='greentext'>You managed to survive the events on [station_name()] as [M.real_name].</span>"

		else
			report_parts += "<span class='redtext'>You did not survive the events on [station_name()]...</span>"

	report_parts += common_report

	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	roundend_report.set_content(report_parts.Join("<br>"))
	roundend_report.add_stylesheet("roundend",'html/browser/roundend.css')
	//roundend_report.stylesheets = list("browserOutput.css") //replace ui styling with chat one
	//TODO Move these to fresh css file so we have a standard of what goes on the report instead of current soup
	
	roundend_report.open(0)

/datum/controller/subsystem/ticker/proc/display_report()
	GLOB.common_report = build_roundend_report()
	for(var/client/C in GLOB.clients)
		show_roundend_report(C,GLOB.common_report)
	give_show_report_button()

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
		. += "<span class='header'>Medal Commendations:</span>"
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


/datum/controller/subsystem/ticker/proc/give_show_report_button()
	for(var/v in GLOB.clients)
		var/client/C = v
		var/datum/action/report/R = new
		C.player_details.player_actions += R
		R.Grant(C.mob)

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "vote"

/datum/action/report/Trigger()
	if(owner && GLOB.common_report && SSticker.current_state == GAME_STATE_FINISHED)
		SSticker.show_roundend_report(owner.client,GLOB.common_report)

/datum/action/report/IsAvailable()
	return 1


/proc/printplayer(datum/mind/ply, fleecheck)
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b> the <b>[ply.assigned_role]</b> and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " <span class='redtext'>died</span>"
		else
			text += " <span class='greentext'>survived</span>"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !(T.z in GLOB.station_z_levels))
				text += " while <span class='redtext'>fleeing the station</span>"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " <span class='redtext'>had their body destroyed</span>"
	return text

/proc/printobjectives(datum/mind/ply)
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in ply.objectives)
		if(objective.check_completion())
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			objective_parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
		count++
	return objective_parts.Join("<br>")