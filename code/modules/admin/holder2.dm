/client/proc/deadmin()
	admins.Remove(ckey)
	if(holder)	del(holder)
	src.clear_admin_verbs()
	admin_list -= src
	return 1

var/list/admin_datums = list()

/datum/admins
	var/rank			= null
	var/client/owner	= null
	var/state			= null	//state = 1 for playing //state = 2 for observing
	var/level			= null

//	var/permissions = 0

//	var/stealth			= 0
	var/fakekey			= null
	var/ooccolor		= "#b82e00"
	var/sound_adminhelp = 0 	//If set to 1 this will play a sound when adminhelps are received.

	var/datum/marked_datum

	var/admincaster_screen = 0	//See newscaster.dm under machinery for a full description
	var/datum/feed_message/admincaster_feed_message = new /datum/feed_message   //These two will act as holders.
	var/datum/feed_channel/admincaster_feed_channel = new /datum/feed_channel
	var/admincaster_signature	//What you'll sign the newsfeeds as

/datum/admins/New(initial_rank)
	admincaster_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	rank = initial_rank
	..()

/datum/admins/Del()
	..()

/datum/admins/Topic(href, href_list)
	..()
	if (usr.client != src.owner)
		world << "\blue [usr.key] has attempted to override the admin panel!"
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		return

	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!src.makeTratiors())
					usr << "\red Unfortunatly there were no candidates available"
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!src.makeChanglings())
					usr << "\red Unfortunatly there were no candidates available"
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!src.makeRevs())
					usr << "\red Unfortunatly there were no candidates available"
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!src.makeCult())
					usr << "\red Unfortunatly there were no candidates available"
			if("5")
				log_admin("[key_name(usr)] has spawned a malf AI.")
				if(!src.makeMalfAImode())
					usr << "\red Unfortunatly there were no candidates available"
			if("6")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!src.makeWizard())
					usr << "\red Unfortunatly there were no candidates available"
			if("7")
				log_admin("[key_name(usr)] has spawned a nuke team.")
				if(!src.makeNukeTeam())
					usr << "\red Unfortunatly there were no candidates available"
			if("8")
				log_admin("[key_name(usr)] has spawned a ninja.")
				src.makeSpaceNinja()
			if("9")
				log_admin("[key_name(usr)] has spawned aliens.")
				src.makeAliens()
			if("10")
				log_admin("[key_name(usr)] has spawned a death squad.")
				if(!src.makeDeathsquad())
					usr << "\red Unfortunatly there were no candidates available"
		return

	if(href_list["call_shuttle"])
		if (src.rank in list("Trial Admin", "Badmin", "Game Admin", "Game Master"))
			if( ticker.mode.name == "blob" )
				alert("You can't call the shuttle during blob!")
				return
			switch(href_list["call_shuttle"])
				if("1")
					if ((!( ticker ) || emergency_shuttle.location))
						return
					emergency_shuttle.incall()
					captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
					log_admin("[key_name(usr)] called the Emergency Shuttle")
					message_admins("\blue [key_name_admin(usr)] called the Emergency Shuttle to the station", 1)

				if("2")
					if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
						return
					switch(emergency_shuttle.direction)
						if(-1)
							emergency_shuttle.incall()
							captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
							log_admin("[key_name(usr)] called the Emergency Shuttle")
							message_admins("\blue [key_name_admin(usr)] called the Emergency Shuttle to the station", 1)
						if(1)
							emergency_shuttle.recall()
							log_admin("[key_name(usr)] sent the Emergency Shuttle back")
							message_admins("\blue [key_name_admin(usr)] sent the Emergency Shuttle back", 1)

			href_list["secretsadmin"] = "check_antagonist"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if(href_list["edit_shuttle_time"])
		if (src.rank in list("Badmin", "Game Admin", "Game Master"))
			emergency_shuttle.settimeleft( input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft() ) as num )
			log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]")
			captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
			message_admins("\blue [key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]", 1)
			href_list["secretsadmin"] = "check_antagonist"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if(href_list["delay_round_end"])
		if (src.rank in list("Badmin", "Game Admin", "Game Master"))
			ticker.delay_end = !ticker.delay_end
			log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
			message_admins("\blue [key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].", 1)
			href_list["secretsadmin"] = "check_antagonist"

	if(href_list["simplemake"])

		if(!href_list["mob"])
			usr << "Invalid mob"
			return

		var/mob/M = locate(href_list["mob"])

		if(!M || !ismob(M))
			usr << "Cannot find mob"
			return

		var/delmob = 0
		var/option = alert("Delete old mob?","Message","Yes","No","Cancel")
		if(option == "Cancel")
			return
		if(option == "Yes")
			delmob = 1

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("\blue [key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]", 1)

		switch(href_list["simplemake"])
			if("observer")
				M.change_mob_type( /mob/dead/observer , null, null, delmob)
			if("drone")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob)
			if("hunter")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob)
			if("queen")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/queen , null, null, delmob)
			if("sentinel")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob)
			if("larva")
				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob)
			if("human")
				M.change_mob_type( /mob/living/carbon/human , null, null, delmob)
			if("metroid")
				M.change_mob_type( /mob/living/carbon/metroid , null, null, delmob)
			if("adultmetroid")
				M.change_mob_type( /mob/living/carbon/metroid/adult , null, null, delmob)
			if("monkey")
				M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob)
			if("robot")
				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob)
			if("cat")
				M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob)
			if("runtime")
				M.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob)
			if("corgi")
				M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob)
			if("ian")
				M.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob)
			if("crab")
				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob)
			if("coffee")
				M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob)
			if("parrot")
				M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob)
			if("polyparrot")
				M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob)
			if("constructarmoured")
				M.change_mob_type( /mob/living/simple_animal/constructarmoured , null, null, delmob)
			if("constructbuilder")
				M.change_mob_type( /mob/living/simple_animal/constructbuilder , null, null, delmob)
			if("constructwraith")
				M.change_mob_type( /mob/living/simple_animal/constructwraith , null, null, delmob)
			if("shade")
				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob)


	/////////////////////////////////////new ban stuff
	if(href_list["unbanf"])
		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unbanpanel()

	if(href_list["unbane"])
		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("\blue [key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]", 1)
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << reason
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		feedback_inc("ban_edit",1)
		unbanpanel()

	/////////////////////////////////////new ban stuff

	if(href_list["jobban2"])
		var/mob/M = locate(href_list["jobban2"])
		if(!M)	//sanity
			alert("Mob no longer exists!")
			return
		if(!M.ckey)	//sanity
			alert("Mob has no ckey")
			return
		if(!job_master)
			usr << "Job Master has not been setup!"
			return
		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(civilian_positions)]'><a href='?src=\ref[src];jobban3=civiliandept;jobban4=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in civilian_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions)]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[dd_replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[dd_replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//pAI isn't technically a job, but it goes in here.
		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'>pAI</a></td>"

		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, "traitor") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'><font color=red>[dd_replacetext("Traitor", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'>[dd_replacetext("Traitor", " ", "&nbsp")]</a></td>"

		//Changeling
		if(jobban_isbanned(M, "changeling") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'><font color=red>[dd_replacetext("Changeling", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'>[dd_replacetext("Changeling", " ", "&nbsp")]</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, "operative") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'><font color=red>[dd_replacetext("Nuke Operative", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'>[dd_replacetext("Nuke Operative", " ", "&nbsp")]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, "revolutionary") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'><font color=red>[dd_replacetext("Revolutionary", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'>[dd_replacetext("Revolutionary", " ", "&nbsp")]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Cultist
		if(jobban_isbanned(M, "cultist") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'><font color=red>[dd_replacetext("Cultist", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'>[dd_replacetext("Cultist", " ", "&nbsp")]</a></td>"

		//Wizard
		if(jobban_isbanned(M, "wizard") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'><font color=red>[dd_replacetext("Wizard", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'>[dd_replacetext("Wizard", " ", "&nbsp")]</a></td>"

/*		//Malfunctioning AI	//Removed Malf-bans because they're a pain to impliment
		if(jobban_isbanned(M, "malf AI") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'><font color=red>[dd_replacetext("Malf AI", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'>[dd_replacetext("Malf AI", " ", "&nbsp")]</a></td>"

		//Alien
		if(jobban_isbanned(M, "alien candidate") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'><font color=red>[dd_replacetext("Alien", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'>[dd_replacetext("Alien", " ", "&nbsp")]</a></td>"

		//Infested Monkey
		if(jobban_isbanned(M, "infested monkey") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'><font color=red>[dd_replacetext("Infested Monkey", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'>[dd_replacetext("Infested Monkey", " ", "&nbsp")]</a></td>"
*/
		jobs += "</tr></table>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x450")
		return

	//JOBBAN'S INNARDS
	if(href_list["jobban3"])
		if (src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  ))
			var/mob/M = locate(href_list["jobban4"])
			if(!M)
				alert("Mob no longer exists!")
				return
			if ((M.client && M.client.holder && (M.client.holder.level > src.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return
			if(!job_master)
				usr << "Job Master has not been setup!"
				return

			//get jobs for department if specified, otherwise just returnt he one job in a list.
			var/list/joblist = list()
			switch(href_list["jobban3"])
				if("commanddept")
					for(var/jobPos in command_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("securitydept")
					for(var/jobPos in security_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("engineeringdept")
					for(var/jobPos in engineering_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("medicaldept")
					for(var/jobPos in medical_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("sciencedept")
					for(var/jobPos in science_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("civiliandept")
					for(var/jobPos in civilian_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				if("nonhumandept")
					joblist += "pAI"
					for(var/jobPos in nonhuman_positions)
						if(!jobPos)	continue
						var/datum/job/temp = job_master.GetJob(jobPos)
						if(!temp) continue
						joblist += temp.title
				else
					joblist += href_list["jobban3"]

			//Create a list of unbanned jobs within joblist
			var/list/notbannedlist = list()
			for(var/job in joblist)
				if(!jobban_isbanned(M, job))
					notbannedlist += job

			//Banning comes first
			if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
				var/reason = input(usr,"Reason?","Please State Reason","") as text|null
				if(reason)
					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] jobbanned [key_name(M)] from [job]. reason: [reason]")
						log_admin("[key_name(usr)] banned [key_name(M)] from [job]")
						feedback_inc("ban_job",1)
						DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
						feedback_add_details("ban_job","- [job]")
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
						if(!msg)	msg = job
						else		msg += ", [job]"
					notes_add(M.ckey, "Banned  from [msg] - [reason]")
					message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [msg]", 1)
					M << "\red<BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG>"
					M << "\red <B>The reason is: [reason]</B>"
					M << "\red Jobban can be lifted only upon request."
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1

			//Unbanning joblist
			//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
			if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
				var/msg
				for(var/job in joblist)
					var/reason = jobban_isbanned(M, job)
					if(!reason) continue //skip if it isn't jobbanned anyway
					switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
						if("Yes")
							ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
							log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
							DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
							feedback_inc("ban_job_unban",1)
							feedback_add_details("ban_job_unban","- [job]")
							jobban_unban(M, job)
							if(!msg)	msg = job
							else		msg += ", [job]"
						else
							continue
				if(msg)
					message_admins("\blue [key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]", 1)
					M << "\red<BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG>"
					href_list["jobban2"] = 1 // lets it fall through and refresh
				return 1
			return 0 //we didn't do anything!

	if (href_list["boot2"])
		if ((src.rank in list( "Moderator", "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["boot2"])
			if (ismob(M))
				if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
					return
				M << "\red You have been kicked from the server"
				log_admin("[key_name(usr)] booted [key_name(M)].")
				message_admins("\blue [key_name_admin(usr)] booted [key_name_admin(M)].", 1)
				//M.client = null
				del(M.client)

	//Player Notes
	if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				notes_show(ckey)
			if("add")
				notes_add(ckey,href_list["text"])
				notes_show(ckey)
			if("remove")
				notes_remove(ckey,text2num(href_list["from"]),text2num(href_list["to"]))
				notes_show(ckey)
		return


	if (href_list["removejobban"])
		if ((src.rank in list("Game Admin", "Game Master"  )))
			var/t = href_list["removejobban"]
			if(t)
				if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
					log_admin("[key_name(usr)] removed [t]")
					message_admins("\blue [key_name_admin(usr)] removed [t]", 1)
					jobban_remove(t)
					href_list["ban"] = 1 // lets it fall through and refresh
					var/t_split = dd_text2list(t, " - ")
					var/key = t_split[1]
					var/job = t_split[2]
					DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	if (href_list["newban"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["newban"])
			if(!ismob(M)) return
			if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					if(mins >= 525600) mins = 525599
					var/reason = input(usr,"Reason?","reason","Griefer") as text|null
					if(!reason)
						return
					AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
					ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
					M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
					M << "\red This is a temporary ban, it will be removed in [mins] minutes."
					feedback_inc("ban_tmp",1)
					DB_ban_record(BANTYPE_TEMP, M, mins, reason)
					feedback_inc("ban_tmp_mins",mins)
					if(config.banappeals)
						M << "\red To try to resolve this matter head to [config.banappeals]"
					else
						M << "\red No ban appeals URL has been set."
					log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
					message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")

					del(M.client)
					//del(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
				if("No")
					var/reason = input(usr,"Reason?","reason","Griefer") as text|null
					if(!reason)
						return
					switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
						if("Cancel")	return
						if("Yes")
							AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
						if("No")
							AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
					M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
					M << "\red This is a permanent ban."
					if(config.banappeals)
						M << "\red To try to resolve this matter head to [config.banappeals]"
					else
						M << "\red No ban appeals URL has been set."
					ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
					log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
					message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
					feedback_inc("ban_perma",1)
					DB_ban_record(BANTYPE_PERMA, M, -1, reason)

					del(M.client)
					//del(M)
				if("Cancel")
					return
	if(href_list["unjobbanf"])
		var/banfolder = href_list["unjobbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBanjob(banfolder))
				unjobbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unjobbanpanel()

	if(href_list["unjobbane"])
		return
/*
	if (href_list["remove"])
		if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/t = href_list["remove"]
			if(t && isgoon(t))
				log_admin("[key_name(usr)] removed [t] from the goonlist.")
				message_admins("\blue [key_name_admin(usr)] removed [t] from the goonlist.")
				remove_goon(t)
*/
	if (href_list["mute"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["mute"])
			var/mute_type = href_list["mute_type"]
			if(istext(mute_type))
				mute_type = text2num(mute_type)
			if(!isnum(mute_type))
				return
			if (ismob(M))
				if(!M.client)
					src << "This mob doesn't have a client tied to it."
					return
				if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
					return

				cmd_admin_mute(M, mute_type)

	if (href_list["c_mode"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			var/dat = {"<B>What mode do you wish to play?</B><HR>"}
			for (var/mode in config.modes)
				dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
			dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
			dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
			dat += {"Now: [master_mode]"}
			usr << browse(dat, "window=c_mode")

	if (href_list["f_secret"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			if (master_mode != "secret")
				return alert(usr, "The game mode has to be secret!", null, null, null, null)
			var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
			for (var/mode in config.modes)
				dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
			dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
			dat += {"Now: [secret_force_mode]"}
			usr << browse(dat, "window=f_secret")

	if (href_list["c_mode2"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			master_mode = href_list["c_mode2"]
			log_admin("[key_name(usr)] set the mode as [master_mode].")
			message_admins("\blue [key_name_admin(usr)] set the mode as [master_mode].", 1)
			world << "\blue <b>The mode is now: [master_mode]</b>"
			Game() // updates the main game menu
			world.save_mode(master_mode)
			.(href, list("c_mode"=1))

	if (href_list["f_secret2"])
		if ((src.rank in list( "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			if (master_mode != "secret")
				return alert(usr, "The game mode has to be secret!", null, null, null, null)
			secret_force_mode = href_list["f_secret2"]
			log_admin("[key_name(usr)] set the forced secret mode as [secret_force_mode].")
			message_admins("\blue [key_name_admin(usr)] set the forced secret mode as [secret_force_mode].", 1)
			Game() // updates the main game menu
			.(href, list("f_secret"=1))

	if (href_list["monkeyone"])
		if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["monkeyone"])
			if(!ismob(M))
				return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/N = M
				log_admin("[key_name(usr)] attempting to monkeyize [key_name(M)]")
				message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(M)]", 1)
				N.monkeyize()
			if(istype(M, /mob/living/silicon))
				alert("The AI can't be monkeyized!", null, null, null, null, null)
				return

	if (href_list["corgione"])
		if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["corgione"])
			if(!ismob(M))
				return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/N = M
				log_admin("[key_name(usr)] attempting to corgize [key_name(M)]")
				message_admins("\blue [key_name_admin(usr)] attempting to corgize [key_name_admin(M)]", 1)
				N.corgize()
			if(istype(M, /mob/living/silicon))
				alert("The AI can't be corgized!", null, null, null, null, null)
				return

	if (href_list["forcespeech"])
		if ((src.rank in list( "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["forcespeech"])
			if (ismob(M))
				var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
				if(!speech)
					return
				M.say(speech)
				speech = sanitize(speech) // Nah, we don't trust them
				log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
				message_admins("\blue [key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]")
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["sendtoprison"])
		if ((src.rank in list( "Moderator", "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))

			var/confirm = alert(usr, "Send to admin prison for the round?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["sendtoprison"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
					return
				//strip their stuff before they teleport into a cell :downs:
				for(var/obj/item/weapon/W in M)
					if(istype(W, /datum/organ/external))
						continue
	//don't strip organs
					M.u_equip(W)
					if (M.client)
						M.client.screen -= W
					if (W)
						W.loc = M.loc
						W.dropped(M)
						W.layer = initial(W.layer)
				//teleport person to cell
				M.Paralyse(5)
				sleep(5) //so they black out before warping
				M.loc = pick(prisonwarp)
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/prisoner = M
					prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
					prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
				spawn(50)
					M << "\red You have been sent to the prison station!"
				log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
				message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

/*
	if (href_list["sendtomaze"])
		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/M = locate(href_list["sendtomaze"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the maze you jerk!", null, null, null, null, null)
					return
				//strip their stuff before they teleport into a cell :downs:
				for(var/obj/item/weapon/W in M)
					if(istype(W, /datum/organ/external))
						continue
	//don't strip organs
					M.u_equip(W)
					if (M.client)
						M.client.screen -= W
					if (W)
						W.loc = M.loc
						W.dropped(M)
						W.layer = initial(W.layer)
				//teleport person to cell
				M.paralysis += 5
				sleep(5)
	//so they black out before warping
				M.loc = pick(mazewarp)
				spawn(50)
					M << "\red You have been sent to the maze! Try and get out alive. In the maze everyone is free game. Kill or be killed."
				log_admin("[key_name(usr)] sent [key_name(M)] to the maze.")
				message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the maze.", 1)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return
*/

	if (href_list["tdome1"])
		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))

			var/confirm = alert(usr, "Confirm?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["tdome1"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the thunderdome you jerk!", null, null, null, null, null)
					return
				for(var/obj/item/W in M)
					if (istype(W,/obj/item))
						if(istype(W, /datum/organ/external))
							continue
						M.u_equip(W)
						if (M.client)
							M.client.screen -= W
						if (W)
							W.loc = M.loc
							W.dropped(M)
							W.layer = initial(W.layer)
				M.Paralyse(5)
				sleep(5)
				M.loc = pick(tdome1)
				spawn(50)
					M << "\blue You have been sent to the Thunderdome."
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)", 1)

	if (href_list["tdome2"])
		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))

			var/confirm = alert(usr, "Confirm?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["tdome2"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the thunderdome you jerk!", null, null, null, null, null)
					return
				for(var/obj/item/W in M)
					if (istype(W,/obj/item))
						if(istype(W, /datum/organ/external))
							continue
						M.u_equip(W)
						if (M.client)
							M.client.screen -= W
						if (W)
							W.loc = M.loc
							W.dropped(M)
							W.layer = initial(W.layer)
				M.Paralyse(5)
				sleep(5)
				M.loc = pick(tdome2)
				spawn(50)
					M << "\blue You have been sent to the Thunderdome."
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)", 1)

	if (href_list["tdomeadmin"])
		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))

			var/confirm = alert(usr, "Confirm?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["tdomeadmin"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the thunderdome you jerk!", null, null, null, null, null)
					return
				M.Paralyse(5)
				sleep(5)
				M.loc = pick(tdomeadmin)
				spawn(50)
					M << "\blue You have been sent to the Thunderdome."
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	if (href_list["tdomeobserve"])
		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))

			var/confirm = alert(usr, "Confirm?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["tdomeobserve"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the thunderdome you jerk!", null, null, null, null, null)
					return
				for(var/obj/item/W in M)
					if (istype(W,/obj/item))
						if(istype(W, /datum/organ/external))
							continue
						M.u_equip(W)
						if (M.client)
							M.client.screen -= W
						if (W)
							W.loc = M.loc
							W.dropped(M)
							W.layer = initial(W.layer)
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/observer = M
					observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
					observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), slot_shoes)
				M.Paralyse(5)
				sleep(5)
				M.loc = pick(tdomeobserve)
				spawn(50)
					M << "\blue You have been sent to the Thunderdome."
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

//	if (href_list["adminauth"])
//		if ((src.rank in list( "Admin Candidate", "Temporary Admin", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
//			var/mob/M = locate(href_list["adminauth"])
//			if (ismob(M) && !M.client.authenticated && !M.client.authenticating)
//				M.client.verbs -= /client/proc/authorize
//				M.client.authenticated = text("admin/[]", usr.client.authenticated)
//				log_admin("[key_name(usr)] authorized [key_name(M)]")
//				message_admins("\blue [key_name_admin(usr)] authorized [key_name_admin(M)]", 1)
//				M.client << text("You have been authorized by []", usr.key)

	if (href_list["revive"])
		if ((src.rank in list( "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/mob/living/M = locate(href_list["revive"])
			if (isliving(M))
				if(config.allow_admin_rev)
					M.revive()
					message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!", 1)
					log_admin("[key_name(usr)] healed / Rrvived [key_name(M)]")
					return
				else
					alert("Admin revive disabled")
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["makeai"]) //Yes, im fucking lazy, so what? it works ... hopefully
		if (src.level>=3)
			var/mob/M = locate(href_list["makeai"])
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				message_admins("\red Admin [key_name_admin(usr)] AIized [key_name_admin(M)]!", 1)
//				if (ticker.mode.name  == "AI malfunction")
//					var/obj/O = locate("landmark*ai")
//					M << "\blue <B>You have been teleported to your new starting location!</B>"
//					M.loc = O.loc
//					M.buckled = null
//				else
//					var/obj/S = locate(text("start*AI"))
//					if ((istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf)))
//						M << "\blue <B>You have been teleported to your new starting location!</B>"
//						M.loc = S.loc
//						M.buckled = null
				//	world << "<b>[M.real_name] is the AI!</b>"
				log_admin("[key_name(usr)] AIized [key_name(M)]")
				H.AIize()
			else
				alert("I cannot allow this.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["makealien"])
		if (src.level>=3)
			var/mob/M = locate(href_list["makealien"])
			if(istype(M, /mob/living/carbon/human))
				usr.client.cmd_admin_alienize(M)
			else
				alert("Wrong mob. Must be human.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if (href_list["makemetroid"])
		if (src.level>=3)
			var/mob/M = locate(href_list["makemetroid"])
			if(istype(M, /mob/living/carbon/human))
				usr.client.cmd_admin_metroidize(M)
			else
				alert("Wrong mob. Must be human.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if (href_list["makerobot"])
		if (src.level>=3)
			var/mob/M = locate(href_list["makerobot"])
			if(istype(M, /mob/living/carbon/human))
				usr.client.cmd_admin_robotize(M)
			else
				alert("Wrong mob. Must be human.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return
	if (href_list["makeanimal"])
		if(src.level>=3)
			var/mob/M = locate(href_list["makeanimal"])
			if(!istype(M, /mob/new_player))
				usr.client.cmd_admin_animalize(M)
			else
				alert("The mob must not be a new_player.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return
/***************** BEFORE**************

	if (href_list["l_players"])
		var/dat = "<B>Name/Real Name/Key/IP:</B><HR>"
		for(var/mob/M in world)
			var/foo = ""
			if (ismob(M) && M.client)
				if(!M.client.authenticated && !M.client.authenticating)
					foo += text("\[ <A HREF='?src=\ref[];adminauth=\ref[]'>Authorize</A> | ", src, M)
				else
					foo += text("\[ <B>Authorized</B> | ")
				if(M.start)
					if(!istype(M, /mob/living/carbon/monkey))
						foo += text("<A HREF='?src=\ref[];monkeyone=\ref[]'>Monkeyize</A> | ", src, M)
					else
						foo += text("<B>Monkeyized</B> | ")
					if(istype(M, /mob/living/silicon/ai))
						foo += text("<B>Is an AI</B> | ")
					else
						foo += text("<A HREF='?src=\ref[];makeai=\ref[]'>Make AI</A> | ", src, M)
					if(M.z != 2)
						foo += text("<A HREF='?src=\ref[];sendtoprison=\ref[]'>Prison</A> | ", src, M)
						foo += text("<A HREF='?src=\ref[];sendtomaze=\ref[]'>Maze</A> | ", src, M)
					else
						foo += text("<B>On Z = 2</B> | ")
				else
					foo += text("<B>Hasn't Entered Game</B> | ")
				foo += text("<A HREF='?src=\ref[];revive=\ref[]'>Heal/Revive</A> | ", src, M)

				foo += text("<A HREF='?src=\ref[];forcespeech=\ref[]'>Say</A> \]", src, M)
			dat += text("N: [] R: [] (K: []) (IP: []) []<BR>", M.name, M.real_name, (M.client ? M.client : "No client"), M.lastKnownIP, foo)

		usr << browse(dat, "window=players;size=900x480")

*****************AFTER******************/

// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable

	if (href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	if (href_list["adminplayervars"])
		var/mob/M = locate(href_list["adminplayervars"])
		if(src && src.owner)
			if(istype(src.owner,/client))
				var/client/cl = src.owner
				cl.debug_variables(M)
			else if(ismob(src.owner))
				var/mob/MO = src.owner
				if(MO.client)
					var/client/cl = MO.client
					cl.debug_variables(M)

	if (href_list["adminplayersubtlemessage"])
		var/mob/M = locate(href_list["adminplayersubtlemessage"])
		if(src && src.owner)
			if(istype(src.owner,/client))
				var/client/cl = src.owner
				cl.cmd_admin_subtle_message(M)
			else if(ismob(src.owner))
				var/mob/MO = src.owner
				if(MO.client)
					var/client/cl = MO.client
					cl.cmd_admin_subtle_message(M)

	if (href_list["adminplayerobservejump"])
		var/mob/M = locate(href_list["adminplayerobservejump"])
		if(src && src.owner)
			var/client/C
			if(istype(src.owner,/client))
				C = src.owner
			else if(ismob(src.owner))
				var/mob/MO = src.owner
				C = MO.client
			if(C)
				if(state == 1)
					C.admin_ghost()
				sleep(2)
				C.jumptomob(M)

	if (href_list["adminplayerobservecoodjump"])

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		if(src && src.owner)
			var/client/C
			if(istype(src.owner,/client))
				C = src.owner
			else if(ismob(src.owner))
				var/mob/MO = src.owner
				C = MO.client
			if(C)
				if(state == 1)
					C.admin_ghost()
				sleep(2)
				C.jumptocoord(x, y, z)

	if (href_list["adminchecklaws"])
		if(src && src.owner)
			output_ai_laws()

	if (href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!M)
			usr << "\blue The mob no longer exists."
			return

		if(src && src.owner)
//			//world <<"Passed the owner-check. Owner is [src.owner]. The mob is [M]."
			var/location_description = ""
			var/special_role_description = ""
			var/health_description = ""
			var/gender_description = ""
			var/turf/T = get_turf(M)

			//Location
			if(T && isturf(T))
//				//world <<"Has a location."
				if(T.loc && isarea(T.loc))
					location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
				else
					location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

			//Job + antagonist
			if(M.mind)
				special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
			else
				special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

			//Health
			if(isliving(M))
				var/mob/living/L = M
				var/status
				switch (M.stat)
					if (0) status = "Alive"
					if (1) status = "<font color='orange'><b>Unconscious</b></font>"
					if (2) status = "<font color='red'><b>Dead</b></font>"
				health_description = "Status = [status]"
				health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
			else
//				world <<"Has no health."
				health_description = "This mob type has no health to speak of."

			//Gener
			if(M.gender in list(MALE,FEMALE))
				gender_description = "[M.gender]"
			else
				gender_description = "<font color='red'><b>[M.gender]</b></font>"

//			world <<"Displaying info about the mob..."
			src.owner << "<b>Info about [M.name]:</b> "
			src.owner << "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]"
			src.owner << "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;"
			src.owner << "Location = [location_description];"
			src.owner << "[special_role_description]"
			src.owner << "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?src=\ref[src];adminplayervars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];adminplayersubtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)"

	if (href_list["adminspawncookie"])
		var/mob/M = locate(href_list["adminspawncookie"])
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand )
			if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand )
				if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
					log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
					message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
					return
				else
					H.update_inv_r_hand()//To ensure the icon appears in the HUD
			else
				H.update_inv_l_hand()
			log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
			message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
			feedback_inc("admin_cookies_spawned",1)
			H << "\blue Your prayers have been answered!! You received the <b>best cookie</b>!"
		else
			src << "\blue The person who prayed is not a human. Cookies cannot be spawned."


	if (href_list["traitor_panel_pp"])
		var/mob/M = locate(href_list["traitor_panel_pp"])
		if(isnull(M))
			usr << "Mob doesn't seem to exist."
			return
		if(!ismob(M))
			usr << "This doen't seem to be a mob."
			return
		show_traitor_panel(M)

	if (href_list["BlueSpaceArtillery"])
		var/mob/target = locate(href_list["BlueSpaceArtillery"])
		if(!target)
			return

		if(!isliving(target))
			src.owner << "That is not a valid target."
			return

		var/mob/living/M = target

		var/choice = alert(src.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No")
		if (choice == "No")
			return

		if(BSACooldown)
			src.owner << "Standby!  Reload cycle in progress!  Gunnary crews ready in five seconds!"
			return

		BSACooldown = 1
		spawn(50)
			BSACooldown = 0


		M << "You've been hit by bluespace artillery!"
		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		var/obj/effect/stop/S
		S = new /obj/effect/stop
		S.victim = M
		S.loc = M.loc
		spawn(20)
			del(S)

		var/turf/T = get_turf(M)
		if(T && (istype(T,/turf/simulated/floor/)))
			if(prob(80))
				T:break_tile_to_plating()
			else
				T:break_tile()

		if(M.health == 1)
			M.gib()
		else
			M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
			M.Stun(20)
			M.Weaken(20)
			M.stuttering = 20

	if (href_list["CentcommReply"])
		var/mob/M = locate(href_list["CentcommReply"])
		if(!M)
			return
		if(!ishuman(M))
			alert("Centcomm cannot transmit to non-humans.")
			return
		var/mob/living/carbon/human/H = M
		if(!istype(H.ears, /obj/item/device/radio/headset))
			alert("The person you're trying to reply to doesn't have a headset!  Centcomm cannot transmit directly to them.")
			return
		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their headset.","Outgoing message from Centcomm", "")
		if(!input)
			return

		src.owner << "You sent [input] to [M] via a secure channel."

		log_admin("[src.owner] replied to [key_name(M)]'s Centcomm message with the message [input].")
		message_admins("[src.owner] replied to [key_name(M)]'s Centcom message with: \"[input]\"")
		M << "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows. [input].  Message ends.\""

		return

	if (href_list["SyndicateReply"])
		var/mob/M = locate(href_list["SyndicateReply"])
		if(!M)
			return
		if(!istype(M, /mob/living/carbon/human))
			alert("The Syndicate cannot transmit to non-humans.")
			return
		if(!istype(M:ears, /obj/item/device/radio/headset))
			alert("The person you're trying to reply to doesn't have a headset!  The Syndicate cannot transmit directly to them.")
			return
		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their headset.","Outgoing message from The Syndicate", "")
		if(!input)
			return

		src.owner << "You sent [input] to [M] via a secure channel."
		log_admin("[src.owner] replied to [key_name(M)]'s Syndicate message with the message [input].")
		M << "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. [input].  Message ends.\""

		return

	if (href_list["jumpto"])
		if(rank in list("Badmin", "Game Admin", "Game Master"))
			var/mob/M = locate(href_list["jumpto"])
			usr.client.jumptomob(M)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if (href_list["getmob"])
		if(rank in list( "Trial Admin", "Badmin", "Game Admin", "Game Master"))

			var/confirm = alert(usr, "Confirm?", "Message", "Yes", "No")
			if(confirm != "Yes")
				return

			var/mob/M = locate(href_list["getmob"])
			usr.client.Getmob(M)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if (href_list["sendmob"])
		if(rank in list( "Trial Admin", "Badmin", "Game Admin", "Game Master"))
			var/mob/M = locate(href_list["sendmob"])
			usr.client.sendmob(M)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if (href_list["narrateto"])
		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	if (href_list["subtlemessage"])
		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	if (href_list["traitor"])
		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return
		var/mob/M = locate(href_list["traitor"])
		if (!istype(M))
			player_panel_new()
			return
		if(isalien(M))
			alert("Is an [M.mind ? M.mind.special_role : "Alien"]!", "[M.key]")
			return
		if (M:mind)
			M:mind.edit_memory()
			return
		alert("Cannot make this mob a traitor! It has no mind!")

	if (href_list["create_object"])
		if (src.rank in list("Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"))
			return create_object(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")

	if (href_list["quick_create_object"])
		if (src.rank in list("Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"))
			return quick_create_object(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")


	if (href_list["create_turf"])
		if (src.rank in list("Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"))
			return create_turf(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")

	if (href_list["create_mob"])
		if (src.rank in list("Badmin", "Game Admin", "Game Master"))
			return create_mob(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")

	if (href_list["prom_demot"])
		if ((src.rank in list("Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/client/C = locate(href_list["prom_demot"])
			if(C.holder && (C.holder.level >= src.level))
				alert("This cannot be done as [C] is a [C.holder.rank]")
				return
			var/dat = "[C] is a [C.holder ? "[C.holder.rank]" : "non-admin"]<br><br>Change [C]'s rank?<br>"
			if(src.level == 6)
			//host
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Game Admin;client4ad=\ref[C]'>Game Admin</A> //coder<BR>
				<A href='?src=\ref[src];chgadlvl=Badmin;client4ad=\ref[C]'>Badmin</A> // Shit Guy<BR>
				<A href='?src=\ref[src];chgadlvl=Trial Admin;client4ad=\ref[C]'>Trial Admin</A> // Primary Administrator<BR>
				<A href='?src=\ref[src];chgadlvl=Admin Candidate;client4ad=\ref[C]'>Admin Candidate</A> // // Administrator<BR>
				<A href='?src=\ref[src];chgadlvl=Temporary Admin;client4ad=\ref[C]'>Temporary Admin</A> // Secondary Admin<BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>Moderator</A> // Moderator<BR>
				<A href='?src=\ref[src];chgadlvl=Admin Observer;client4ad=\ref[C]'>Admin Observer</A> // Filthy Xeno<BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else if(src.level == 5)
			//coder
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Badmin;client4ad=\ref[C]'>Badmin</A> // Shit Guy<BR>
				<A href='?src=\ref[src];chgadlvl=Trial Admin;client4ad=\ref[C]'>Trial Admin</A> // Primary Administrator<BR>
				<A href='?src=\ref[src];chgadlvl=Admin Candidate;client4ad=\ref[C]'>Admin Candidate</A> // // Administrator<BR>
				<A href='?src=\ref[src];chgadlvl=Temporary Admin;client4ad=\ref[C]'>Temporary Admin</A> // Secondary Admin<BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>Moderator</A> // Moderator<BR>
				<A href='?src=\ref[src];chgadlvl=Admin Observer;client4ad=\ref[C]'>Admin Observer</A> // Filthy Xeno<BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else
				alert("Not a high enough level admin, sorry.")
				return
			usr << browse(dat, "window=prom_demot;size=480x300")

	if (href_list["chgadlvl"])
	//change admin level
		var/rank = href_list["chgadlvl"]
		var/client/C = locate(href_list["client4ad"])
		if(!istype(C))	return
		if(rank == "Remove")
			log_admin("[key_name(usr)] has removed [C]'s adminship")
			message_admins("[key_name_admin(usr)] has removed [C]'s adminship", 1)
			C.deadmin()
		else
			if(C == owner)	//no promoting/demoting yourself
				message_admins("[C] tried to change their own admin-rank >:(")
				return
			C.update_admins(rank)
			log_admin("[key_name(usr)] has made [C] a [rank]")
			message_admins("[key_name_admin(usr)] has made [C] a [rank]", 1)
//			admins[C.ckey] = rank
//			admin_list |= C


	if (href_list["object_list"])
		if (src.rank in list("Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"))
			if (config.allow_admin_spawning && ((src.state == 2) || (src.rank in list("Badmin", "Game Admin", "Game Master"))))
				var/atom/loc = usr.loc

				var/dirty_paths
				if (istext(href_list["object_list"]))
					dirty_paths = list(href_list["object_list"])
				else if (istype(href_list["object_list"], /list))
					dirty_paths = href_list["object_list"]

				var/paths = list()
				var/removed_paths = list()
				for (var/dirty_path in dirty_paths)
					var/path = text2path(dirty_path)
					if (!path)
						removed_paths += dirty_path
					else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
						removed_paths += dirty_path
					else if (ispath(path, /obj/item/weapon/gun/energy/pulse_rifle) && !(src.rank in list("Game Admin", "Game Master")))
						removed_paths += dirty_path
					else if (ispath(path, /obj/item/weapon/melee/energy/blade))//Not an item one should be able to spawn./N
						removed_paths += dirty_path
					else if (ispath(path, /obj/effect/bhole) && !(src.rank in list("Game Admin", "Game Master")))
						removed_paths += dirty_path
					else if (ispath(path, /mob) && !(src.rank in list("Badmin", "Game Admin", "Game Master")))
						removed_paths += dirty_path

					else
						paths += path

				if (!paths)
					return
				else if (length(paths) > 5)
					alert("Select fewer object types, (max 5)")
					return
				else if (length(removed_paths))
					alert("Removed:\n" + dd_list2text(removed_paths, "\n"))

				var/list/offset = dd_text2list(href_list["offset"],",")
				var/number = dd_range(1, 100, text2num(href_list["object_count"]))
				var/X = offset.len > 0 ? text2num(offset[1]) : 0
				var/Y = offset.len > 1 ? text2num(offset[2]) : 0
				var/Z = offset.len > 2 ? text2num(offset[3]) : 0
				var/tmp_dir = href_list["object_dir"]
				var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
				if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
					obj_dir = 2
				var/obj_name = sanitize(href_list["object_name"])
				var/where = href_list["object_where"]
				if (!( where in list("onfloor","inhand","inmarked") ))
					where = "onfloor"

				//TODO ERRORAGE
				if( where == "inhand" )
					usr << "Support for inhand not available yet. Will spawn on floor."
					where = "onfloor"
				//END TODO ERRORAGE

				if ( where == "inhand" )	//Can only give when human or monkey
					if ( !( ishuman(usr) || ismonkey(usr) ) )
						usr << "Can only spawn in hand when you're a human or a monkey."
						where = "onfloor"
					else if ( usr.get_active_hand() )
						usr << "Your active hand is full. Spawning on floor."
						where = "onfloor"
				if ( where == "inmarked" )
					if ( !marked_datum )
						usr << "You don't have any object marked. Abandoning spawn."
						return
					else
						if ( !istype(marked_datum,/atom) )
							usr << "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn."
							return

				var/atom/target //Where the object will be spawned
				switch ( where )
					if ( "onfloor" )
						switch (href_list["offset_type"])
							if ("absolute")
								target = locate(0 + X,0 + Y,0 + Z)
							if ("relative")
								target = locate(loc.x + X,loc.y + Y,loc.z + Z)
					if ( "inmarked" )
						target = marked_datum


				//TODO ERRORAGE - Give support for "inhand"

				if(target)
					for (var/path in paths)
						for (var/i = 0; i < number; i++)
							var/atom/O = new path(target)
							if(O)
								O.dir = obj_dir
								if(obj_name)
									O.name = obj_name
									if(istype(O,/mob))
										var/mob/M = O
										M.real_name = obj_name

				if (number == 1)
					log_admin("[key_name(usr)] created a [english_list(paths)]")
					for(var/path in paths)
						if(ispath(path, /mob))
							message_admins("[key_name_admin(usr)] created a [english_list(paths)]", 1)
							break
				else
					log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
					for(var/path in paths)
						if(ispath(path, /mob))
							message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]", 1)
							break
				return
			else
				alert("You cannot spawn items right now.")
				return

	if (href_list["secretsfun"])
		if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/ok = 0
			switch(href_list["secretsfun"])
				if("sec_clothes")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","SC")
					for(var/obj/item/clothing/under/O in world)
						del(O)
					ok = 1
				if("sec_all_clothes")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","SAC")
					for(var/obj/item/clothing/O in world)
						del(O)
					ok = 1
				if("sec_classic1")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","SC1")
					for(var/obj/item/clothing/suit/fire/O in world)
						del(O)
					for(var/obj/structure/grille/O in world)
						del(O)
/*					for(var/obj/machinery/vehicle/pod/O in world)
						for(var/mob/M in src)
							M.loc = src.loc
							if (M.client)
								M.client.perspective = MOB_PERSPECTIVE
								M.client.eye = M
						del(O)
					ok = 1*/
				if("toxic")
				/*
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","T")
					for(var/obj/machinery/atmoalter/siphs/fullairsiphon/O in world)
						O.t_status = 3
					for(var/obj/machinery/atmoalter/siphs/scrubbers/O in world)
						O.t_status = 1
						O.t_per = 1000000.0
					for(var/obj/machinery/atmoalter/canister/O in world)
						if (!( istype(O, /obj/machinery/atmoalter/canister/oxygencanister) ))
							O.t_status = 1
							O.t_per = 1000000.0
						else
							O.t_status = 3
				*/
					usr << "HEH"
				if("monkey")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","M")
					for(var/mob/living/carbon/human/H in mob_list)
						spawn(0)
							H.monkeyize()
					ok = 1
				if("corgi")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","M")
					for(var/mob/living/carbon/human/H in mob_list)
						spawn(0)
							H.corgize()
					ok = 1
				if("power")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","P")
					log_admin("[key_name(usr)] made all areas powered", 1)
					message_admins("\blue [key_name_admin(usr)] made all areas powered", 1)
					power_restore()
				if("unpower")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","UP")
					log_admin("[key_name(usr)] made all areas unpowered", 1)
					message_admins("\blue [key_name_admin(usr)] made all areas unpowered", 1)
					power_failure()
				if("quickpower")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","QP")
					log_admin("[key_name(usr)] made all SMESs powered", 1)
					message_admins("\blue [key_name_admin(usr)] made all SMESs powered", 1)
					power_restore_quick()
				if("activateprison")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","AP")
					world << "\blue <B>Transit signature detected.</B>"
					world << "\blue <B>Incoming shuttle.</B>"
					/*
					var/A = locate(/area/shuttle_prison)
					for(var/atom/movable/AM as mob|obj in A)
						AM.z = 1
						AM.Move()
					*/
					message_admins("\blue [key_name_admin(usr)] sent the prison shuttle to the station.", 1)
				if("deactivateprison")
					/*
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","DP")
					var/A = locate(/area/shuttle_prison)
					for(var/atom/movable/AM as mob|obj in A)
						AM.z = 2
						AM.Move()
					*/
					message_admins("\blue [key_name_admin(usr)] sent the prison shuttle back.", 1)
				if("toggleprisonstatus")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","TPS")
					for(var/obj/machinery/computer/prison_shuttle/PS in world)
						PS.allowedtocall = !(PS.allowedtocall)
						message_admins("\blue [key_name_admin(usr)] toggled status of prison shuttle to [PS.allowedtocall].", 1)
				if("prisonwarp")
					if(!ticker)
						alert("The game hasn't started yet!", null, null, null, null, null)
						return
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","PW")
					message_admins("\blue [key_name_admin(usr)] teleported all players to the prison station.", 1)
					for(var/mob/living/carbon/human/H in mob_list)
						var/turf/loc = find_loc(H)
						var/security = 0
						if(loc.z > 1 || prisonwarped.Find(H))
	//don't warp them if they aren't ready or are already there
							continue
						H.Paralyse(5)
						if(H.wear_id)
							var/obj/item/weapon/card/id/id = H.get_idcard()
							for(var/A in id.access)
								if(A == access_security)
									security++
						if(!security)
							//strip their stuff before they teleport into a cell :downs:
							for(var/obj/item/weapon/W in H)
								if(istype(W, /datum/organ/external))
									continue
									//don't strip organs
								H.u_equip(W)
								if (H.client)
									H.client.screen -= W
								if (W)
									W.loc = H.loc
									W.dropped(H)
									W.layer = initial(W.layer)
							//teleport person to cell
							H.loc = pick(prisonwarp)
							H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
							H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
						else
							//teleport security person
							H.loc = pick(prisonsecuritywarp)
						prisonwarped += H
				if("traitor_all")
					if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						if(!ticker)
							alert("The game hasn't started yet!")
							return
						var/objective = copytext(sanitize(input("Enter an objective")),1,MAX_MESSAGE_LEN)
						if(!objective)
							return
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","TA([objective])")
						for(var/mob/living/carbon/human/H in player_list)
							if(H.stat == 2 || !H.client || !H.mind) continue
							if(is_special_character(H)) continue
							//traitorize(H, objective, 0)
							ticker.mode.traitors += H.mind
							H.mind.special_role = "traitor"
							var/datum/objective/new_objective = new
							new_objective.owner = H
							new_objective.explanation_text = objective
							H.mind.objectives += new_objective
							ticker.mode.greet_traitor(H.mind)
							//ticker.mode.forge_traitor_objectives(H.mind)
							ticker.mode.finalize_traitor(H.mind)
						for(var/mob/living/silicon/A in player_list)
							ticker.mode.traitors += A.mind
							A.mind.special_role = "traitor"
							var/datum/objective/new_objective = new
							new_objective.owner = A
							new_objective.explanation_text = objective
							A.mind.objectives += new_objective
							ticker.mode.greet_traitor(A.mind)
							ticker.mode.finalize_traitor(A.mind)
						message_admins("\blue [key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]", 1)
						log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")
					else
						alert("You're not of a high enough rank to do this")
				if("moveminingshuttle")
					if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						if(mining_shuttle_moving)
							return
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","ShM")
						move_mining_shuttle()
						message_admins("\blue [key_name_admin(usr)] moved mining shuttle", 1)
						log_admin("[key_name(usr)] moved the mining shuttle")
					else
						alert("You're not of a high enough rank to do this")
				if("moveadminshuttle")
					if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","ShA")
						move_admin_shuttle()
						message_admins("\blue [key_name_admin(usr)] moved the centcom administration shuttle", 1)
						log_admin("[key_name(usr)] moved the centcom administration shuttle")
					else
						alert("You're not of a high enough rank to do this")
				if("moveferry")
					if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","ShF")
						move_ferry()
						message_admins("\blue [key_name_admin(usr)] moved the centcom ferry", 1)
						log_admin("[key_name(usr)] moved the centcom ferry")
					else
						alert("You're not of a high enough rank to do this")
				if("movealienship")
					if ((src.rank in list( "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","ShX")
						move_alien_ship()
						message_admins("\blue [key_name_admin(usr)] moved the alien dinghy", 1)
						log_admin("[key_name(usr)] moved the alien dinghy")
					else
						alert("You're not of a high enough rank to do this")
				if("togglebombcap")
					if (src.rank in list( "Game Admin", "Game Master"  ))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","BC")
						switch(MAX_EXPLOSION_RANGE)
							if(14)
								MAX_EXPLOSION_RANGE = 16
							if(16)
								MAX_EXPLOSION_RANGE = 20
							if(20)
								MAX_EXPLOSION_RANGE = 28
							if(28)
								MAX_EXPLOSION_RANGE = 56
							if(56)
								MAX_EXPLOSION_RANGE = 128
							if(128)
								MAX_EXPLOSION_RANGE = 14
						var/range_dev = MAX_EXPLOSION_RANGE *0.25
						var/range_high = MAX_EXPLOSION_RANGE *0.5
						var/range_low = MAX_EXPLOSION_RANGE
						message_admins("\red <b> [key_name_admin(usr)] changed the bomb cap to [range_dev], [range_high], [range_low]</b>", 1)
						log_admin("[key_name_admin(usr)] changed the bomb cap to [MAX_EXPLOSION_RANGE]")
					else
						alert("No way. You're not of a high enough rank to do this.")

				if("flicklights")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","FL")
					while(!usr.stat)
	//knock yourself out to stop the ghosts
						for(var/mob/M in player_list)
							if(M.stat != 2 && prob(25))
								var/area/AffectedArea = get_area(M)
								if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
									AffectedArea.power_light = 0
									AffectedArea.power_change()
									spawn(rand(55,185))
										AffectedArea.power_light = 1
										AffectedArea.power_change()
									var/Message = rand(1,4)
									switch(Message)
										if(1)
											M.show_message(text("\blue You shudder as if cold..."), 1)
										if(2)
											M.show_message(text("\blue You feel something gliding across your back..."), 1)
										if(3)
											M.show_message(text("\blue Your eyes twitch, you feel like something you can't see is here..."), 1)
										if(4)
											M.show_message(text("\blue You notice something moving out of the corner of your eye, but nothing is there..."), 1)
									for(var/obj/W in orange(5,M))
										if(prob(25) && !W.anchored)
											step_rand(W)
						sleep(rand(100,1000))
					for(var/mob/M in player_list)
						if(M.stat != 2)
							M.show_message(text("\blue The chilling wind suddenly stops..."), 1)
	/*				if("shockwave")
					ok = 1
					world << "\red <B><big>ALERT: STATION STRESS CRITICAL</big></B>"
					sleep(60)
					world << "\red <B><big>ALERT: STATION STRESS CRITICAL. TOLERABLE LEVELS EXCEEDED!</big></B>"
					sleep(80)
					world << "\red <B><big>ALERT: STATION STRUCTURAL STRESS CRITICAL. SAFETY MECHANISMS FAILED!</big></B>"
					sleep(40)
					for(var/mob/M in world)
						shake_camera(M, 400, 1)
					for(var/obj/structure/window/W in world)
						spawn(0)
							sleep(rand(10,400))
							W.ex_act(rand(2,1))
					for(var/obj/structure/grille/G in world)
						spawn(0)
							sleep(rand(20,400))
							G.ex_act(rand(2,1))
					for(var/obj/machinery/door/D in world)
						spawn(0)
							sleep(rand(20,400))
							D.ex_act(rand(2,1))
					for(var/turf/station/floor/Floor in world)
						spawn(0)
							sleep(rand(30,400))
							Floor.ex_act(rand(2,1))
					for(var/obj/structure/cable/Cable in world)
						spawn(0)
							sleep(rand(30,400))
							Cable.ex_act(rand(2,1))
					for(var/obj/structure/closet/Closet in world)
						spawn(0)
							sleep(rand(30,400))
							Closet.ex_act(rand(2,1))
					for(var/obj/machinery/Machinery in world)
						spawn(0)
							sleep(rand(30,400))
							Machinery.ex_act(rand(1,3))
					for(var/turf/station/wall/Wall in world)
						spawn(0)
							sleep(rand(30,400))
							Wall.ex_act(rand(2,1)) */
				if("wave")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","MW")
					if ((src.rank in list("Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
						meteor_wave()
						message_admins("[key_name_admin(usr)] has spawned meteors", 1)
						command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
						world << sound('sound/AI/meteors.ogg')
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
						return
				if("gravanomalies")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","GA")
					command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
					world << sound('sound/AI/granomalies.ogg')
					var/turf/T = pick(blobstart)
					var/obj/effect/bhole/bh = new /obj/effect/bhole( T.loc, 30 )
					spawn(rand(100, 600))
						del(bh)

				if("timeanomalies")	//dear god this code was awful :P Still needs further optimisation
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","STA")
					//moved to its own dm so I could split it up and prevent the spawns copying variables over and over
					//can be found in code\game\game_modes\events\wormholes.dm
					wormhole_event()

				if("goblob")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","BL")
					mini_blob_event()
					message_admins("[key_name_admin(usr)] has spawned blob", 1)
				if("aliens")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","AL")
					if(aliens_allowed)
						alien_infestation()
						message_admins("[key_name_admin(usr)] has spawned aliens", 1)
				if("comms_blackout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","CB")
					var/answer = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No")
					if(answer == "Yes")
						communications_blackout(0)
					else
						communications_blackout(1)
					message_admins("[key_name_admin(usr)] triggered a communications blackout.", 1)
				if("spaceninja")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","SN")
					if(toggle_space_ninja)
						if(space_ninja_arrival())//If the ninja is actually spawned. They may not be depending on a few factors.
							message_admins("[key_name_admin(usr)] has sent in a space ninja", 1)
				if("carp")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","C")
					var/choice = input("You sure you want to spawn carp?") in list("Badmin", "Cancel")
					if(choice == "Badmin")
						message_admins("[key_name_admin(usr)] has spawned carp.", 1)
						carp_migration()
				if("radiation")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","R")
					message_admins("[key_name_admin(usr)] has has irradiated the station", 1)
					high_radiation_event()
				if("immovable")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","IR")
					message_admins("[key_name_admin(usr)] has sent an immovable rod to the station", 1)
					immovablerod()
				if("prison_break")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","PB")
					message_admins("[key_name_admin(usr)] has allowed a prison break", 1)
					prison_break()
				if("lightout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","LO")
					message_admins("[key_name_admin(usr)] has broke a lot of lights", 1)
					lightsout(1,2)
				if("blackout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","BO")
					message_admins("[key_name_admin(usr)] broke all lights", 1)
					lightsout(0,0)
				if("whiteout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","WO")
					for(var/obj/machinery/light/L in world)
						L.fix()
					message_admins("[key_name_admin(usr)] fixed all lights", 1)
				if("friendai")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","FA")
					for(var/mob/aiEye/aE in mob_list)
						aE.icon_state = "ai_friend"
					for(var/obj/machinery/M in machines)
						if(istype(M, /obj/machinery/ai_status_display))
							var/obj/machinery/ai_status_display/A = M
							A.emotion = "Friend Computer"
						else if(istype(M, /obj/machinery/status_display))
							var/obj/machinery/status_display/A = M
							A.friendc = 1
					message_admins("[key_name_admin(usr)] turned all AIs into best friends.", 1)
				if("floorlava")
					if(floorIsLava)
						usr << "The floor is lava already."
						return
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","LF")

					//Options
					var/length = input(usr, "How long will the lava last? (in seconds)", "Length", 180) as num
					length = min(abs(length), 1200)

					var/damage = input(usr, "How deadly will the lava be?", "Damage", 2) as num
					damage = min(abs(damage), 100)

					var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "YES!", "Nah")
					if(sure == "Nah")
						return
					floorIsLava = 1

					message_admins("[key_name_admin(usr)] made the floor LAVA! It'll last [length] seconds and it will deal [damage] damage to everyone.", 1)

					for(var/turf/simulated/floor/F in world)
						if(F.z == 1)
							F.name = "lava"
							F.desc = "The floor is LAVA!"
							F.overlays += "lava"
							F.lava = 1

					spawn(0)
						for(var/i = i, i < length, i++) // 180 = 3 minutes
							if(damage)
								for(var/mob/living/carbon/L in living_mob_list)
									if(istype(L.loc, /turf/simulated/floor)) // Are they on LAVA?!
										var/turf/simulated/floor/F = L.loc
										if(F.lava)
											var/safe = 0
											for(var/obj/structure/O in F.contents)
												if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
													safe = 1
													break
											if(!safe)
												L.adjustFireLoss(damage)


							sleep(10)

						for(var/turf/simulated/floor/F in world) // Reset everything.
							if(F.z == 1)
								F.name = initial(F.name)
								F.desc = initial(F.desc)
								F.overlays = null
								F.lava = 0
								F.update_icon()
						floorIsLava = 0
					return
				if("virus")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","V")
					var/answer = alert("Do you want this to be a random disease or do you have something in mind?",,"Virus2","Random","Choose")
					if(answer=="Random")
						viral_outbreak()
						message_admins("[key_name_admin(usr)] has triggered a virus outbreak", 1)
					else if(answer == "Choose")
						var/list/viruses = list("fake gbs","gbs","magnitis","wizarditis",/*"beesease",*/"brain rot","cold","retrovirus","flu","pierrot's throat","rhumba beat")
						var/V = input("Choose the virus to spread", "BIOHAZARD") in viruses
						viral_outbreak(V)
						message_admins("[key_name_admin(usr)] has triggered a virus outbreak of [V]", 1)
					else
						usr << "Nope"
						/*
						var/lesser = (alert("Do you want to infect the mob with a major or minor disease?",,"Major","Minor") == "Minor")
						var/mob/living/carbon/victim = input("Select a mob to infect", "Virus2") as null|mob in world
						if(!istype(victim)) return
						if(lesser)
							infect_mob_random_lesser(victim)
						else
							infect_mob_random_greater(victim)
						message_admins("[key_name_admin(usr)] has infected [victim] with a [lesser ? "minor" : "major"] virus2.", 1)
						*/
				if("retardify")
					if (src.rank in list("Badmin", "Game Admin", "Game Master"))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","RET")
						for(var/mob/living/carbon/human/H in player_list)
							H << "\red <B>You suddenly feel stupid.</B>"
							H.setBrainLoss(60)
						message_admins("[key_name_admin(usr)] made everybody retarded")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("fakeguns")
					if (src.rank in list("Badmin", "Game Admin", "Game Master"))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","FG")
						for(var/obj/item/W in world)
							if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
								continue
							W.icon = 'icons/obj/gun.dmi'
							W.icon_state = "revolver"
							W.item_state = "gun"
						message_admins("[key_name_admin(usr)] made every item look like a gun")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("schoolgirl")
					if (src.rank in list("Badmin", "Game Admin", "Game Master"))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","SG")
						for(var/obj/item/clothing/under/W in world)
							W.icon_state = "schoolgirl"
							W.item_state = "w_suit"
							W.color = "schoolgirl"
						message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
						world << sound('sound/AI/animes.ogg')
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("dorf")
					if (src.rank in list("Badmin","Game Admin", "Game Master"))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","DF")
						for(var/mob/living/carbon/human/B in mob_list)
							B.f_style = "Dward Beard"
							B.update_hair()
						message_admins("[key_name_admin(usr)] activated dorf mode")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("ionstorm")
					if (src.rank in list("Badmin","Game Admin", "Game Master"))
						feedback_inc("admin_secrets_fun_used",1)
						feedback_add_details("admin_secrets_fun_used","I")
						IonStorm()
						message_admins("[key_name_admin(usr)] triggered an ion storm")
						var/show_log = alert(usr, "Show ion message?", "Message", "Yes", "No")
						if(show_log == "Yes")
							command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert")
							world << sound('sound/AI/ionstorm.ogg')
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("spacevines")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","K")
					spacevine_infestation()
					message_admins("[key_name_admin(usr)] has spawned spacevines", 1)
			if (usr)
				log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
				if (ok)
					world << text("<B>A secret has been activated by []!</B>", usr.key)
		return

	if (href_list["secretsadmin"])
		if ((src.rank in list( "Moderator", "Temporary Admin", "Admin Candidate", "Trial Admin", "Badmin", "Game Admin", "Game Master"  )))
			var/ok = 0
			switch(href_list["secretsadmin"])
				if("clear_bombs")
					//I do nothing
				if("list_bombers")
					var/dat = "<B>Bombing List<HR>"
					for(var/l in bombers)
						dat += text("[l]<BR>")
					usr << browse(dat, "window=bombers")
				if("list_signalers")
					var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
					for(var/sig in lastsignalers)
						dat += "[sig]<BR>"
					usr << browse(dat, "window=lastsignalers;size=800x500")
				if("list_lawchanges")
					var/dat = "<B>Showing last [length(lawchanges)] law changes.</B><HR>"
					for(var/sig in lawchanges)
						dat += "[sig]<BR>"
					usr << browse(dat, "window=lawchanges;size=800x500")
				if("list_job_debug")
					var/dat = "<B>Job Debug info.</B><HR>"
					if(job_master)
						for(var/line in job_master.job_debug)
							dat += "[line]<BR>"
						dat+= "*******<BR><BR>"
						for(var/datum/job/job in job_master.occupations)
							if(!job)	continue
							dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
						usr << browse(dat, "window=jobdebug;size=600x500")
				if("check_antagonist")
					check_antagonists()
				if("showailaws")
					output_ai_laws()
				if("showgm")
					if(!ticker)
						alert("The game hasn't started yet!")
					else if (ticker.mode)
						alert("The game mode is [ticker.mode.name]")
					else alert("For some reason there's a ticker, but not a game mode")
				if("manifest")
					var/dat = "<B>Showing Crew Manifest.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
					for(var/mob/living/carbon/human/H in mob_list)
						if(H.ckey)
							dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
					dat += "</table>"
					usr << browse(dat, "window=manifest;size=440x410")
				if("DNA")
					var/dat = "<B>Showing DNA from blood.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
					for(var/mob/living/carbon/human/H in mob_list)
						if(H.dna && H.ckey)
							dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.b_type]</td></tr>"
					dat += "</table>"
					usr << browse(dat, "window=DNA;size=440x410")
				if("fingerprints")
					var/dat = "<B>Showing Fingerprints.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
					for(var/mob/living/carbon/human/H in mob_list)
						if(H.ckey)
							if(H.dna && H.dna.uni_identity)
								dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
							else if(H.dna && !H.dna.uni_identity)
								dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
							else if(!H.dna)
								dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
					dat += "</table>"
					usr << browse(dat, "window=fingerprints;size=440x410")
				else
			if (usr)
				log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
				if (ok)
					world << text("<B>A secret has been activated by []!</B>", usr.key)
		return
	if (href_list["secretscoder"])
		if ((src.rank in list( "Badmin", "Game Admin", "Game Master" )))
			switch(href_list["secretscoder"])
				if("spawn_objects")
					var/dat = "<B>Admin Log<HR></B>"
					for(var/l in admin_log)
						dat += "<li>[l]</li>"
					if(!admin_log.len)
						dat += "No-one has done anything this round!"
					usr << browse(dat, "window=admin_log")
				if("maint_access_brig")
					for(var/obj/machinery/door/airlock/maintenance/M in world)
						if (access_maint_tunnels in M.req_access)
							M.req_access = list(access_brig)
					message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
				if("maint_access_engiebrig")
					for(var/obj/machinery/door/airlock/maintenance/M in world)
						if (access_maint_tunnels in M.req_access)
							M.req_access = list()
							M.req_one_access = list(access_brig,access_engine)
					message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
				if("infinite_sec")
					var/datum/job/J = job_master.GetJob("Security Officer")
					if(!J) return
					J.total_positions = -1
					J.spawn_positions = -1
					message_admins("[key_name_admin(usr)] has removed the cap on security officers.")
		return
		//hahaha


	if(href_list["ac_view_wanted"])                 //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()
	if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = strip_html_simple(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,lentext(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.admincaster_feed_channel.channel_name
				newChannel.author = src.admincaster_signature
				newChannel.locked = src.admincaster_feed_channel.locked
				newChannel.is_admin_channel = 1
				feedback_inc("newscaster_channels",1)
				news_network.network_channels += newChannel                        //Adding channel to the global network
				log_admin("[key_name_admin(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = src.admincaster_signature
			newMsg.body = src.admincaster_feed_message.body
			newMsg.is_admin_message = 1
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					break
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name_admin(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = adminscrub(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.author," ") == 1)
			src.admincaster_feed_message.author = copytext(admincaster_feed_message.author,2,lentext(admincaster_feed_message.author)+1)
		src.access_news_network()

	if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,lentext(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name_admin(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	if(href_list["ac_refresh"])
		src.access_news_network()

	if(href_list["ac_set_signature"])
		src.admincaster_signature = adminscrub(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()