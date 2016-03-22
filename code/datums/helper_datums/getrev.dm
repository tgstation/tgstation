var/global/datum/getrev/revdata = new()

/datum/getrev
	var/parentcommit
	var/commit
	var/list/testmerge = list()
	var/date

/datum/getrev/New()
	var/head_file = return_file_text(".git/logs/HEAD")
	var/regex/head_log = new("(\\w{40}) (\\w{40}).+> (\\d{10}).+\n\\Z")
	head_log.Find(head_file)
	parentcommit = head_log.group[1]
	commit = head_log.group[2]
	var/unix_time = text2num(head_log.group[3])
	if(SERVERTOOLS && fexists("..\\prtestjob.lk"))
		testmerge = file2list("..\\prtestjob.lk")
	date = unix2date(unix_time)
	world.log << "Running /tg/ revision:"
	world.log << "[date]"
	world.log << commit
	if(testmerge.len)
		for(var/line in testmerge)
			if(line)
				world.log << "Test merge active of PR #[line]"
		world.log << "Based off master commit [parentcommit]"
	world.log << "Current map - [MAP_NAME]" //can't think of anywhere better to put it

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	set desc = "Check the current server code revision"

	if(revdata.commit)
		src << "<b>Server revision compiled on:</b> [revdata.date]"
		if(revdata.testmerge.len)
			for(var/line in revdata.testmerge)
				if(line)
					src << "Test merge active of PR <a href='[config.githuburl]/pull/[line]'>#[line]</a>"
			src << "Based off master commit <a href='[config.githuburl]/commit/[revdata.parentcommit]'>[revdata.parentcommit]</a>"
		else
			src << "<a href='[config.githuburl]/commit/[revdata.commit]'>[revdata.commit]</a>"
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
		src <<"<b>Game Mode Odds:</b>"
		var/sum = 0
		for(var/i=1,i<=config.probabilities.len,i++)
			sum += config.probabilities[config.probabilities[i]]
		for(var/i=1,i<=config.probabilities.len,i++)
			if(config.probabilities[config.probabilities[i]] > 0)
				var/percentage = round(config.probabilities[config.probabilities[i]] / sum * 100, 0.1)
				src << "[config.probabilities[i]] [percentage]%"
	return
