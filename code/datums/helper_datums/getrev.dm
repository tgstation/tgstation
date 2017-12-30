/datum/getrev
	var/originmastercommit
	var/commit
	var/list/testmerge = list()
	var/date

/datum/getrev/New()
	testmerge = SERVER_TOOLS_PR_LIST
	log_world("Running /tg/ revision:")
	var/list/logs = world.file2list(".git/logs/HEAD")
	if(logs)
		logs = splittext(logs[logs.len - 1], " ")
		date = unix2date(text2num(logs[5]))
		commit = logs[2]
		log_world("[date]")
	logs = world.file2list(".git/logs/refs/remotes/origin/master")
	if(logs)
		originmastercommit = splittext(logs[logs.len - 1], " ")[2]

	if(testmerge.len)
		log_world(commit)
		for(var/line in testmerge)
			if(line)
				var/tmcommit = testmerge[line]["commit"]
				log_world("Test merge active of PR #[line] commit [tmcommit]")
				SSblackbox.record_feedback("nested tally", "testmerged_prs", 1, list("[line]", "[tmcommit]"))
		log_world("Based off origin/master commit [originmastercommit]")
	else
		log_world(originmastercommit)

/datum/getrev/proc/GetTestMergeInfo(header = TRUE)
	if(!testmerge.len)
		return ""
	. = header ? "The following pull requests are currently test merged:<br>" : ""
	for(var/line in testmerge)
		var/cm = testmerge[line]["commit"]
		var/details = ": '" + html_encode(testmerge[line]["title"]) + "' by " + html_encode(testmerge[line]["author"]) + " at commit " + html_encode(copytext(cm, 1, min(length(cm), 7)))
		if(details && findtext(details, "\[s\]") && (!usr || !usr.client.holder))
			continue
		. += "<a href=\"[CONFIG_GET(string/githuburl)]/pull/[line]\">#[line][details]</a><br>"

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	if(GLOB.round_id)
		to_chat(src, "<b>Round ID:</b> [GLOB.round_id]")
	if(GLOB.revdata.originmastercommit)
		to_chat(src, "<b>Server revision compiled on:</b> [GLOB.revdata.date]")
		var/prefix = ""
		if(GLOB.revdata.testmerge.len)
			to_chat(src, GLOB.revdata.GetTestMergeInfo())
			prefix = "Based off origin/master commit: "
		var/pc = GLOB.revdata.originmastercommit
		to_chat(src, "[prefix]<a href=\"[CONFIG_GET(string/githuburl)]/commit/[pc]\">[copytext(pc, 1, min(length(pc), 7))]</a>")
	else
		to_chat(src, "Revision unknown")
	if(SERVER_TOOLS_PRESENT)
		to_chat(src, "Server tools version: [SERVER_TOOLS_VERSION]")
		to_chat(src, "Server tools API version: [SERVER_TOOLS_API_VERSION]")
	to_chat(src, "<b>Current Informational Settings:</b>")
	to_chat(src, "Protect Authority Roles From Traitor: [CONFIG_GET(flag/protect_roles_from_antagonist)]")
	to_chat(src, "Protect Assistant Role From Traitor: [CONFIG_GET(flag/protect_assistant_from_antagonist)]")
	to_chat(src, "Enforce Human Authority: [CONFIG_GET(flag/enforce_human_authority)]")
	to_chat(src, "Allow Latejoin Antagonists: [CONFIG_GET(flag/allow_latejoin_antagonists)]")
	to_chat(src, "Enforce Continuous Rounds: [length(CONFIG_GET(keyed_flag_list/continuous))] of [config.modes.len] roundtypes")
	to_chat(src, "Allow Midround Antagonists: [length(CONFIG_GET(keyed_flag_list/midround_antag))] of [config.modes.len] roundtypes")
	if(CONFIG_GET(flag/show_game_type_odds))
		var/list/probabilities = CONFIG_GET(keyed_number_list/probability)
		if(SSticker.IsRoundInProgress())
			var/prob_sum = 0
			var/current_odds_differ = FALSE
			var/list/probs = list()
			var/list/modes = config.gamemode_cache
			var/list/min_pop = CONFIG_GET(keyed_number_list/min_pop)
			var/list/max_pop = CONFIG_GET(keyed_number_list/max_pop)
			for(var/mode in modes)
				var/datum/game_mode/M = mode
				var/ctag = initial(M.config_tag)
				if(!(ctag in probabilities))
					continue
				if((min_pop[ctag] && (min_pop[ctag] > SSticker.totalPlayersReady)) || (max_pop[ctag] && (max_pop[ctag] < SSticker.totalPlayersReady)) || (initial(M.required_players) > SSticker.totalPlayersReady))
					current_odds_differ = TRUE
					continue
				probs[ctag] = 1
				prob_sum += probabilities[ctag]
			if(current_odds_differ)
				to_chat(src, "<b>Game Mode Odds for current round:</b>")
				for(var/ctag in probs)
					if(probabilities[ctag] > 0)
						var/percentage = round(probabilities[ctag] / prob_sum * 100, 0.1)
						to_chat(src, "[ctag] [percentage]%")

		to_chat(src, "<b>All Game Mode Odds:</b>")
		var/sum = 0
		for(var/ctag in probabilities)
			sum += probabilities[ctag]
		for(var/ctag in probabilities)
			if(probabilities[ctag] > 0)
				var/percentage = round(probabilities[ctag] / sum * 100, 0.1)
				to_chat(src, "[ctag] [percentage]%")
