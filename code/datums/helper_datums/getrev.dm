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
		world.log << "Unable to get revision info."
		spawn()
			del src

	New(filename)
		..()
		if(!fexists(filename))
			return abort()

		var/text = file2text(file(filename))
		if(!text)
			diary << "Unable to get [filename] contents, aborting"
			return abort()

		var/list/CL = tg_text2list(text, "\n")
		for (var/t in CL)
			if (!t)
				continue
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
			var/list/filelist = dd_file2list("[svndirpath]/entries",null)
			if(filelist.len < 4)
				return abort()
			revision = filelist[4]
			commiter = filelist[12]
			world.log << "Running TG Revision Number: [revision]."
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
	if(revdata)
		output = revdata.showInfo()

		output += "Current Infomational Settings: <br>"
		output += "Tensioner Status: [config.Tensioner_Active]<br>"
		//output += "Current Tension: [tension_master.score]<br>"
		//output += "Tensioner Debug Data:  R1:[tension_master.round1] R2:[tension_master.round2] R3:[tension_master.round3] R4:[tension_master.round4] ES: [tension_master.eversupressed] CD: [tension_master.cooldown]<br>"
		output += "Protect Authority Roles From Tratior: [config.protect_roles_from_antagonist]<br>"
	usr << browse(output,"window=revdata");
	return
