/*
/proc/SetupJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
	return 1

	var/text = file2text(jobsfile)

	if(!text)
		world << "No jobs.txt found, using defaults."
		return

	var/list/jobEntries = dd_text2list(text, "\n")

	world << "\red \b Setting up jobs..."

	for(var/job in jobEntries)
		if (!job)
			continue

		job = trim(job)
		if (!length(job))
			continue

		var/pos = findtext(job, "=")
		var/name = null
		var/value = null

		if (pos)
			name = copytext(job, 1, pos)
			value = copytext(job, pos + 1)
		else
			continue

		if(name && value)
			occupations[name] = text2num(value)

		if(name && value)
			jobMax[name] = text2num(value)

	world << "\red \b Jobs set up!"

	return
*/

//TODO: put these somewhere else
/client/proc/mimewall()
	set category = "Mime"
	set name = "Invisible wall"
	set desc = "Create an invisible wall on your location."
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!usr.miming)
		usr << "You still haven't atoned for your speaking transgression. Wait."
		return
	usr.verbs -= /client/proc/mimewall
	spawn(300)
		usr.verbs += /client/proc/mimewall
	for (var/mob/V in viewers(usr))
		if(V!=usr)
			V.show_message("[usr] looks as if a wall is in front of them.", 3, "", 2)
	usr << "You form a wall in front of yourself."
	var/obj/effect/forcefield/F =  new /obj/effect/forcefield(locate(usr.x,usr.y,usr.z))
	F.icon_state = "empty"
	F.name = "invisible wall"
	F.desc = "You have a bad feeling about this."
	spawn (300)
		del (F)
	return

/client/proc/mimespeak()
	set category = "Mime"
	set name = "Speech"
	set desc = "Toggle your speech."
	if(usr.miming)
		usr.miming = 0
	else
		usr << "You'll have to wait if you want to atone for your sins."
		spawn(3000)
			usr.miming = 1
	return
