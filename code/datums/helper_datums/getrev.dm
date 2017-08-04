/datum/getrev
	var/originmastercommit
	var/commit
	var/list/testmerge = list()
	var/has_pr_details = FALSE	//tgs2 support
	var/date

/datum/getrev/New()
	if(world.RunningService() && fexists(SERVICE_PR_TEST_JSON))
		testmerge = json_decode(file2text(SERVICE_PR_TEST_JSON))
#ifdef SERVERTOOLS
	else if(!world.RunningService() && fexists("../prtestjob.lk"))	//tgs2 support
		var/list/tmp = world.file2list("..\\prtestjob.lk")
		for(var/I in tmp)
			if(I)
				testmerge |= I
#endif
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
				if(world.RunningService())
					var/tmcommit = testmerge[line]["commit"]
					log_world("Test merge active of PR #[line] commit [tmcommit]")
					SSblackbox.add_details("testmerged_prs","[line]|[tmcommit]")
				else //tgs2 support
					log_world("Test merge active of PR #[line]")
					SSblackbox.add_details("testmerged_prs","[line]")
		log_world("Based off origin/master commit [originmastercommit]")
	else
		log_world(originmastercommit)
/datum/getrev/proc/DownloadPRDetails()
	if(!config.githubrepoid)
		if(testmerge.len)
			log_world("PR details download failed: No github repo config set")
		return
	if(!isnum(text2num(config.githubrepoid)))
		log_world("PR details download failed: Invalid github repo id: [config.githubrepoid]")
		return
	for(var/line in testmerge)
		if(!isnum(text2num(line)))
			log_world("PR details download failed: Invalid PR number: [line]")
			return

		var/url = "https://api.github.com/repositories/[config.githubrepoid]/pulls/[line].json"
		GLOB.valid_HTTPSGet = TRUE
		var/json = HTTPSGet(url)
		if(!json)
			return

		testmerge[line] = json_decode(json)

		if(!testmerge[line])
			log_world("PR details download failed: null details returned")
			return
		CHECK_TICK
	log_world("PR details successfully downloaded")
	has_pr_details = TRUE

/datum/getrev/proc/GetTestMergeInfo(header = TRUE)
	if(!testmerge.len)
		return ""
	. = header ? "The following pull requests are currently test merged:<br>" : ""
	for(var/line in testmerge)
		var/details
		if(world.RunningService())
			var/cm = testmerge[line]["commit"]
			details = ": '" + html_encode(testmerge[line]["title"]) + "' by " + html_encode(testmerge[line]["author"]) + " at commit " + html_encode(copytext(cm, 1, min(length(cm), 7)))
		else if(has_pr_details)	//tgs2 support
			details = ": '" + html_encode(testmerge[line]["title"]) + "' by " + html_encode(testmerge[line]["user"]["login"])
		if(details && findtext(details, "\[s\]") && (!usr || !usr.client.holder))
			continue
		. += "<a href=\"[config.githuburl]/pull/[line]\">#[line][details]</a><br>"

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	if(GLOB.revdata.originmastercommit)
		to_chat(src, "<b>Server revision compiled on:</b> [GLOB.revdata.date]")
		var/prefix = ""
		if(GLOB.revdata.testmerge.len)
			to_chat(src, GLOB.revdata.GetTestMergeInfo())
			prefix = "Based off origin/master commit: "
		var/pc = GLOB.revdata.originmastercommit
		to_chat(src, "[prefix]<a href=\"[config.githuburl]/commit/[pc]\">[copytext(pc, 1, min(length(pc), 7))]</a>")
	else
		to_chat(src, "Revision unknown")
	to_chat(src, "<b>Current Infomational Settings:</b>")
	to_chat(src, "Protect Authority Roles From Traitor: [config.protect_roles_from_antagonist]")
	to_chat(src, "Protect Assistant Role From Traitor: [config.protect_assistant_from_antagonist]")
	to_chat(src, "Enforce Human Authority: [config.enforce_human_authority]")
	to_chat(src, "Allow Latejoin Antagonists: [config.allow_latejoin_antagonists]")
	to_chat(src, "Enforce Continuous Rounds: [config.continuous.len] of [config.modes.len] roundtypes")
	to_chat(src, "Allow Midround Antagonists: [config.midround_antag.len] of [config.modes.len] roundtypes")
	if(config.show_game_type_odds)
		if(SSticker.IsRoundInProgress())
			var/prob_sum = 0
			var/current_odds_differ = FALSE
			var/list/probs = list()
			var/list/modes = config.gamemode_cache
			for(var/mode in modes)
				var/datum/game_mode/M = mode
				var/ctag = initial(M.config_tag)
				if(!(ctag in config.probabilities))
					continue
				if((config.min_pop[ctag] && (config.min_pop[ctag] > SSticker.totalPlayersReady)) || (config.max_pop[ctag] && (config.max_pop[ctag] < SSticker.totalPlayersReady)) || (initial(M.required_players) > SSticker.totalPlayersReady))
					current_odds_differ = TRUE
					continue
				probs[ctag] = 1
				prob_sum += config.probabilities[ctag]
			if(current_odds_differ)
				to_chat(src, "<b>Game Mode Odds for current round:</b>")
				for(var/ctag in probs)
					if(config.probabilities[ctag] > 0)
						var/percentage = round(config.probabilities[ctag] / prob_sum * 100, 0.1)
						to_chat(src, "[ctag] [percentage]%")

		to_chat(src, "<b>All Game Mode Odds:</b>")
		var/sum = 0
		for(var/ctag in config.probabilities)
			sum += config.probabilities[ctag]
		for(var/ctag in config.probabilities)
			if(config.probabilities[ctag] > 0)
				var/percentage = round(config.probabilities[ctag] / sum * 100, 0.1)
				to_chat(src, "[ctag] [percentage]%")
