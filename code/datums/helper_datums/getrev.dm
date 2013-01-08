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
			del src

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

client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	var/output =  "Sorry, the revision info is unavailable."
	output = file2text("/home/bay12/live/data/gitcommit")
	output += "Current Infomational Settings: <br>"
	output += "Protect Authority Roles From Tratior: [config.protect_roles_from_antagonist]<br>"
	usr << browse(output,"window=revdata");
	return
