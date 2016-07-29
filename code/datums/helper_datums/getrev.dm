<<<<<<< HEAD
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
=======
/*
 * This datum gets revision info from local svn 'entries' file
 * Path to the directory containing it should be in 'config/svndir.txt' file
 *
 */

var/global/datum/getrev/revdata = new("config/svndir.txt")

//Oh yeah, I'm an OOP fag, lalala
/datum/getrev
	var/revision
	var/commiter
	var/svndirpath
	var/revhref

	proc/abort()
		spawn()
			qdel (src)

	New(filename)
		..()
		var/list/Lines = file2list(filename)
		if(!Lines.len)	return abort()
		for(var/t in Lines)
			if(!t)	continue
			t = trim(t)
			if (length(t) == 0)
				continue
			else if (copytext(t, 1, 2) == "#")
				continue
			var/pos = findtext(t, " ")
			var/name = null
			var/value = null
			if (pos)
				name = lowertext(copytext(t, 1, pos))
				value = copytext(t, pos + 1)
			else
				name = lowertext(t)
			if(!name)
				continue
			switch(name)
				if("svndir")
					svndirpath = value
				if("revhref")
					revhref = value

		if(svndirpath && fexists(svndirpath) && fexists("[svndirpath]/entries") && isfile(file("[svndirpath]/entries")))
			var/list/filelist = file2list("[svndirpath]/entries")
			var/s_archive = "" //Stores the previous line so the revision owner can be assigned.

			//This thing doesn't count blank lines, so doing filelist[4] isn't working.
			for(var/s in filelist)
				if(!commiter)
					if(s == "has-props")//The line before this is the committer.
						commiter = s_archive
				if(!revision)
					var/n = text2num(s)
					if(isnum(n))
						if(n > 5000 && n < 99999) //Do you think we'll still be up and running at r100000? :) ~Errorage
							revision = s
				if(revision && commiter)
					break
				s_archive = s
			if(!revision)
				abort()
			diary << "Revision info loaded succesfully"
			return
		return abort()

	proc/getRevisionText()
		var/output
		if(revhref)
			output = {"<a href="[revhref][revision]">[revision]</a>"}
		else
			output = revision
		return output

	proc/showInfo()
		return {"<html>
					<head>
					</head>
					<body>
					<p><b>Server Revision:</b> [getRevisionText()]<br/>
					<b>Author:</b> [commiter]</p>
					</body>
					<html>"}

/proc/return_revision()
	var/output =  "Sorry, the revision info is unavailable."
	output = file2text(".git/refs/heads/Bleeding-Edge")
	if(!output || output == "")
		output = "Unable to load revision info from HEAD"
	return output

/client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	var/output =  "Sorry, the revision info is unavailable."
	output = file2text(".git/refs/heads/Bleeding-Edge")
	if(!output || output == "")
		output = "Unable to load revision info from HEAD"

	output += {"Current Infomational Settings: <br>
		Protect Authority Roles From Tratior: [config.protect_roles_from_antagonist]<br>"}
	usr << browse(output,"window=revdata");
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
