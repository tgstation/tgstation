var/global/datum/getrev/revdata = new()

/datum/getrev
	var/parentcommit
	var/commit
	var/list/testmerge = list()
	var/date

/datum/getrev/New()
	var/head_file = return_file_text(".git/logs/HEAD")
	if(SERVERTOOLS && fexists("..\\prtestjob.lk"))
		testmerge = file2list("..\\prtestjob.lk")
	var/testlen = max(testmerge.len - 1, 0)
	var/regex/head_log = new("(\\w{40}) .+> (\\d{10}).+(?=(\n.*(\\w{40}).*){[testlen]}\n*\\Z)")
	head_log.Find(head_file)
	parentcommit = head_log.group[1]
	date = unix2date(text2num(head_log.group[2]))
	commit = head_log.group[4]
	world.log << "Running /tg/ revision:"
	world.log << "[date]"
	if(testmerge.len)
		world.log << commit
		for(var/line in testmerge)
			if(line)
				world.log << "Test merge active of PR #[line]"
		world.log << "Based off master commit [parentcommit]"
	else
		world.log << parentcommit
	world.log << "Current map - [MAP_NAME]" //can't think of anywhere better to put it

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	if(revdata.parentcommit)
		src << "<b>Server revision compiled on:</b> [revdata.date]"
		if(revdata.testmerge.len)
			for(var/line in revdata.testmerge)
				if(line)
					src << "Test merge active of PR <a href='[config.githuburl]/pull/[line]'>#[line]</a>"
			src << "Based off master commit <a href='[config.githuburl]/commit/[revdata.parentcommit]'>[revdata.parentcommit]</a>"
		else
			src << "<a href='[config.githuburl]/commit/[revdata.parentcommit]'>[revdata.parentcommit]</a>"
	else
		src << "Revision unknown"
	src << "<b>Current Infomational Settings:</b>"
	src << "Protect Authority Roles From Traitor: [config.protect_roles_from_antagonist]"
	src << "Protect Assistant Role From Traitor: [config.protect_assistant_from_antagonist]"
	src << "Enforce Human Authority: [config.enforce_human_authority]"
	src << "Allow Latejoin Antagonists: [config.allow_latejoin_antagonists]"
	src << "Enforce Continuous Rounds: [config.continuous.len] of [config.modes.len] roundtypes"
	src << "Allow Midround Antagonists: [config.midround_antag.len] of [config.modes.len] roundtypes"
	if(config.show_game_type_odds)
		if(ticker.current_state == GAME_STATE_PLAYING)
			src <<"<b>Game Mode Odds for current round:</b>"
			var/prob_sum = 0
			var/list/probs = list()
			var/list/modes = config.gamemode_cache
			for(var/mode in modes)
				var/datum/game_mode/M = mode
				var/ctag = initial(M.config_tag)
				if(!(ctag in config.probabilities))
					continue
				if((config.min_pop[ctag] && (config.min_pop[ctag] > ticker.totalPlayersReady)) || (initial(M.required_players) > ticker.totalPlayersReady))
					continue
				if(config.max_pop[ctag] && (config.max_pop[ctag] < ticker.totalPlayersReady))
					continue
				probs[ctag] = 1
				prob_sum += config.probabilities[ctag]
			for(var/ctag in probs)
				if(config.probabilities[ctag] > 0)
					var/percentage = round(config.probabilities[ctag] / prob_sum * 100, 0.1)
					src << "[ctag] [percentage]%"
		
		src <<"<b>All Game Mode Odds:</b>"
		var/sum = 0
		for(var/ctag in config.probabilities)
			sum += config.probabilities[ctag]
		for(var/ctag in config.probabilities)
			if(config.probabilities[ctag] > 0)
				var/percentage = round(config.probabilities[ctag] / sum * 100, 0.1)
				src << "[ctag] [percentage]%"
	return