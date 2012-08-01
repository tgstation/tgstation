
var/global/BSACooldown = 0


////////////////////////////////
/proc/message_admins(var/text, var/admin_ref = 0, var/admin_holder_ref = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	log_adminwarn(rendered)
	for (var/client/C in admin_list)
		if (C)
			var/msg = rendered
			if (admin_ref)
				msg = dd_replaceText(msg, "%admin_ref%", "\ref[C]")
			if (admin_holder_ref && C.holder)
				msg = dd_replaceText(msg, "%holder_ref%", "\ref[C.holder]")
			C << msg


/obj/admins/Topic(href, href_list)
	..()
	if (usr.client != src.owner)
		world << "\blue [usr.key] has attempted to override the admin panel!"
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
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
			if("drprofessor")
				M.change_mob_type( /mob/living/simple_animal/parrot/DrProfessor , null, null, delmob)
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
		var/mins = 0
		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]
		var/minutes = (Banlist["minutes"] - CMinutes)
		if(!minutes || minutes < 0) minutes = 0
		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",minutes ? minutes : 1440) as num
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				reason = input(usr,"Reason?","reason",reason2) as text
				if(!reason)
					return
			if("No")
				temp = 0
				reason = input(usr,"Reason?","reason",reason2) as text
				if(!reason)
					return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [GetExp(mins)]")

		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [GetExp(mins)]")
		message_admins("\blue [key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [GetExp(mins)]", 1)
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << reason
		Banlist["temp"] << temp
		Banlist["minutes"] << (mins + CMinutes)
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
				var/speech = copytext(sanitize(input("What will [key_name(M)] say?.", "Force speech", "")),1,MAX_MESSAGE_LEN)
				if(!speech)
					return
				M.say(speech)
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
					prisoner.equip_if_possible(new /obj/item/clothing/under/color/orange(prisoner), prisoner.slot_w_uniform)
					prisoner.equip_if_possible(new /obj/item/clothing/shoes/orange(prisoner), prisoner.slot_shoes)
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
					observer.equip_if_possible(new /obj/item/clothing/under/suit_jacket(observer), observer.slot_w_uniform)
					observer.equip_if_possible(new /obj/item/clothing/shoes/black(observer), observer.slot_shoes)
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
			if(istype(src.owner,/client))
				var/client/cl = src.owner
				cl.admin_observe()
				sleep(2)
				cl.jumptomob(M)
			else if(ismob(src.owner))
				var/mob/MO = src.owner
				if(MO.client)
					var/client/cl = MO.client
					cl.admin_observe()
					sleep(2)
					cl.jumptomob(M)

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
					if (1) status = "\yellow Unconscious"
					if (2) status = "\red Dead"
				health_description = "Status - [status]"
				health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
			else
//				world <<"Has no health."
				health_description = "This mob type has no health to speak of."

//			world <<"Displaying info about the mob..."
			src.owner << "<b>Info about [M.name]:</b> "
			src.owner << "Mob type = [M.type]; Damage = [health_description]"
			src.owner << "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Original_name = [M.original_name]; Key = <b>[M.key]</b>;"
			src.owner << "Location = [location_description];"
			src.owner << "[special_role_description]"
			src.owner << "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?src=\ref[src];adminplayervars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];adminplayersubtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)"

	if (href_list["adminspawncookie"])
		var/mob/M = locate(href_list["adminspawncookie"])
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.equip_if_possible( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), H.slot_l_hand )
			if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				H.equip_if_possible( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), H.slot_r_hand )
				if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
					log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
					message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
					return
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
		if(!istype(M, /mob/living/carbon/human))
			alert("Centcomm cannot transmit to non-humans.")
			return
		if(!istype(M:ears, /obj/item/device/radio/headset))
			alert("The person you're trying to reply to doesn't have a headset!  Centcomm cannot transmit directly to them.")
			return
		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their headset.","Outgoing message from Centcomm", "")
		if(!input)
			return

		src.owner << "You sent [input] to [M] via a secure channel."
		log_admin("[src.owner] replied to [key_name(M)]'s Centcomm message with the message [input].")
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
	if (href_list["vmode"])
		vmode()

	if (href_list["votekill"])
		votekill()

	if (href_list["voteres"])
		voteres()

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
			C.clear_admin_verbs()
			C.update_admins(null)
			log_admin("[key_name(usr)] has removed [C]'s adminship")
			message_admins("[key_name_admin(usr)] has removed [C]'s adminship", 1)
			admins.Remove(C.ckey)
			admin_list -= C
		else
			if(C == owner)	//no promoting/demoting yourself
				message_admins("[C] tried to change their own admin-rank >:(")
				return
			C.clear_admin_verbs()
			C.update_admins(rank)
			log_admin("[key_name(usr)] has made [C] a [rank]")
			message_admins("[key_name_admin(usr)] has made [C] a [rank]", 1)
			admins[C.ckey] = rank
			admin_list |= C


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
							H.equip_if_possible(new /obj/item/clothing/under/color/orange(H), H.slot_w_uniform)
							H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), H.slot_shoes)
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
							ticker.mode.greet_traitor(H)
							//ticker.mode.forge_traitor_objectives(H.mind)
							ticker.mode.finalize_traitor(H)
						for(var/mob/living/silicon/A in player_list)
							ticker.mode.traitors += A.mind
							A.mind.special_role = "traitor"
							var/datum/objective/new_objective = new
							new_objective.owner = A
							new_objective.explanation_text = objective
							A.mind.objectives += new_objective
							ticker.mode.greet_traitor(A)
							ticker.mode.finalize_traitor(A)
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
						world << sound('meteors.ogg')
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
						return
				if("gravanomalies")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","GA")
					command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
					world << sound('granomalies.ogg')
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
				if("lightsout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","LO")
					message_admins("[key_name_admin(usr)] has broke a lot of lights", 1)
					lightsout(1,2)
				if("blackout")
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","BO")
					message_admins("[key_name_admin(usr)] broke all lights", 1)
					lightsout(0,0)
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
						world << sound('animes.ogg')
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
							world << sound('ionstorm.ogg')
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

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/obj/admins/proc/show_player_panel(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		usr << "You seem to be selecting a mob that doesn't exist anymore."
		return
	if (!istype(src,/obj/admins))
		src = usr.client.holder
	if (!istype(src,/obj/admins))
		usr << "Error: you are not an admin!"
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		if(M.client.holder)
			body += "\[<A href='?src=\ref[src];prom_demot=\ref[M.client]'>[M.client.holder.rank]</A>\]"
		else
			body += "\[<A href='?src=\ref[src];prom_demot=\ref[M.client]'>Player</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Heal</A>\] "

	body += "<br><br>\[ "
	body += "<a href='?src=\ref[src];adminplayervars=\ref[M]'>VV</a> - "
	body += "<a href='?src=\ref[src];traitor_panel_pp=\ref[M]'>TP</a> - "
	body += "<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> - "
	body += "<a href='?src=\ref[src];adminplayersubtlemessage=\ref[M]'>SM</a> - "
	body += "<a href='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</a>\] </b><br>"

	body += "<b>Mob type</b> = [M.type]<br><br>"

	body += "<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> | "
	body += "<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> | "
	body += "<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> | "
	body += "<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A> "

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		body += "<br><b>Mute: </b> "
		body += "\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(M.client.muted_ic)?"red":"blue"]'>IC</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(M.client.muted_ooc)?"red":"blue"]'>OOC</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(M.client.muted_pray)?"red":"blue"]'>PRAY</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(M.client.muted_adminhelp)?"red":"blue"]'>ADMINHELP</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(M.client.muted_deadchat)?"red":"blue"]'>DEADCHAT</font></a>\]"
		body += "(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'>toggle all</a>)"

	body += "<br><br>"
	body += "<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> | "
	body += "<A href='?src=\ref[src];getmob=\ref[M]'>Get</A>"

	body += "<br><br>"
	body += "<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | "
	body += "<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> | "
	body += "<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A>"

	if (M.client)
		if(!istype(M, /mob/new_player))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += "<A href='?src=\ref[src];makeai=\ref[M]'>Make AI</A> | "
				body += "<A href='?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> | "
				body += "<A href='?src=\ref[src];makealien=\ref[M]'>Make Alien</A> | "
				body += "<A href='?src=\ref[src];makemetroid=\ref[M]'>Make Metroid</A> "

			body += "<br><br>"
			body += "<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>"
			body += "<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A> | "
			body += "\[ Alien: <A href='?src=\ref[src];simplemake=drone;mob=\ref[M]'>Drone</A>, "
			body += "<A href='?src=\ref[src];simplemake=hunter;mob=\ref[M]'>Hunter</A>, "
			body += "<A href='?src=\ref[src];simplemake=queen;mob=\ref[M]'>Queen</A>, "
			body += "<A href='?src=\ref[src];simplemake=sentinel;mob=\ref[M]'>Sentinel</A>, "
			body += "<A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A> \] "
			body += "<A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A> "
			body += "\[ Metroid: <A href='?src=\ref[src];simplemake=metroid;mob=\ref[M]'>Baby</A>, "
			body += "<A href='?src=\ref[src];simplemake=adultmetroid;mob=\ref[M]'>Adult</A> \] "
			body += "<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A> | "
			body += "<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A> | "
			body += "<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A> | "
			body += "<A href='?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Runtime</A> | "
			body += "<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A> | "
			body += "<A href='?src=\ref[src];simplemake=ian;mob=\ref[M]'>Ian</A> | "
			body += "<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A> | "
			body += "<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A> | "
			//body += "<A href='?src=\ref[src];simplemake=parrot;mob=\ref[M]'>Parrot</A> | "
			//body += "<A href='?src=\ref[src];simplemake=drprofessor;mob=\ref[M]'>DrProfessor</A> | "
			body += "\[ Construct: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A> , "
			body += "<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A> , "
			body += "<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \] "
			body += "<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>"
			body += "<br>"

	if (M.client)
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A> | "
		body += "<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> | "
		body += "<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> | "
		body += "<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> | "
		body += "<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> | "

	body += "<br>"
	body += "</body></html>"

	usr << browse(body, "window=adminplayeropts;size=550x515")
	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/obj/admins/proc/Jobbans()

	if ((src.rank in list( "Game Admin", "Game Master"  )))
		var/dat = "<B>Job Bans!</B><HR><table>"
		for(var/t in jobban_keylist)
			var/r = t
			if( findtext(r,"##") )
				r = copytext( r, 1, findtext(r,"##") )//removes the description
			dat += text("<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
		dat += "</table>"
		usr << browse(dat, "window=ban;size=400x400")

/obj/admins/proc/Game()

	var/dat
	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Temporary Admin")
			lvl = 2
		if("Admin Candidate")
			lvl = 3
		if("Trial Admin")
			lvl = 4
		if("Badmin")
			lvl = 5
		if("Game Admin")
			lvl = 6
		if("Game Master")
			lvl = 7

	dat += "<center><B>Game Panel</B></center><hr>\n"

	if(lvl > 0)

//			if(lvl >= 2 )
		dat += "<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>"

	if(lvl > 0 && master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += "<BR>"

	if(lvl >= 3 )
		dat += "<A href='?src=\ref[src];create_object=1'>Create Object</A><br>"
		dat += "<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>"
		dat += "<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>"
	if(lvl >= 5)
		dat += "<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>"
//			if(lvl == 6 )
	usr << browse(dat, "window=admin2;size=210x180")
	return
/*
/obj/admins/proc/goons()
	var/dat = "<HR><B>GOOOOOOONS</B><HR><table cellspacing=5><tr><th>Key</th><th>SA Username</th></tr>"
	for(var/t in goon_keylist)
		dat += text("<tr><td><A href='?src=\ref[src];remove=[ckey(t)]'><B>[t]</B></A></td><td>[goon_keylist[ckey(t)]]</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=300x400")

/obj/admins/proc/beta_testers()
	var/dat = "<HR><B>Beta testers</B><HR><table cellspacing=5><tr><th>Key</th></tr>"
	for(var/t in beta_tester_keylist)
		dat += text("<tr><td>[t]</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=300x400")
*/
/obj/admins/proc/Secrets()
	if (!usr.client.holder)
		return

	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Temporary Admin")
			lvl = 2
		if("Admin Candidate")
			lvl = 3
		if("Trial Admin")
			lvl = 4
		if("Badmin")
			lvl = 5
		if("Game Admin")
			lvl = 6
		if("Game Master")
			lvl = 7

	var/dat = {"
<B>Choose a secret, any secret at all.</B><HR>
<B>Admin Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsadmin=clear_bombs'>Remove all bombs currently in existence</A><BR>
<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR><BR>
<BR>"}
	if(lvl > 2)
		dat += {"
<B>'Random' Events</B><BR>
<BR>
<A href='?src=\ref[src];secretsfun=wave'>Spawn a wave of meteors</A><BR>
<A href='?src=\ref[src];secretsfun=gravanomalies'>Spawn a gravitational anomaly (Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=timeanomalies'>Spawn wormholes (Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=goblob'>Spawn blob(Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=aliens'>Trigger an Alien infestation</A><BR>
<A href='?src=\ref[src];secretsfun=spaceninja'>Send in a space ninja</A><BR>
<A href='?src=\ref[src];secretsfun=carp'>Trigger an Carp migration</A><BR>
<A href='?src=\ref[src];secretsfun=radiation'>Irradiate the station</A><BR>
<A href='?src=\ref[src];secretsfun=prison_break'>Trigger a Prison Break</A><BR>
<A href='?src=\ref[src];secretsfun=virus'>Trigger a Virus Outbreak</A><BR>
<A href='?src=\ref[src];secretsfun=immovable'>Spawn an Immovable Rod</A><BR>
<A href='?src=\ref[src];secretsfun=lightsout'>Toggle a "lights out" event</A><BR>
<A href='?src=\ref[src];secretsfun=ionstorm'>Spawn an Ion Storm</A><BR>
<A href='?src=\ref[src];secretsfun=spacevines'>Spawn Space-Vines</A><BR>
<BR>
<B>Fun Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A><BR>
<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
<A href='?src=\ref[src];secretsfun=toxic'>Toxic Air (WARNING: dangerous)</A><BR>
<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
<A href='?src=\ref[src];secretsfun=toggleprisonstatus'>Toggle Prison Shuttle Status(Use with S/R)</A><BR>
<A href='?src=\ref[src];secretsfun=activateprison'>Send Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=deactivateprison'>Return Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A><BR>
<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A><BR>
<A href='?src=\ref[src];secretsfun=moveadminshuttle'>Move Administration Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=moveferry'>Move Ferry</A><BR>
<A href='?src=\ref[src];secretsfun=movealienship'>Move Alien Dinghy</A><BR>
<A href='?src=\ref[src];secretsfun=moveminingshuttle'>Move Mining Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>"}
//<A href='?src=\ref[src];secretsfun=shockwave'>Station Shockwave</A><BR>

	if(lvl >= 6)
		dat += {"
<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>
		"}

	dat += "<BR>"

	if(lvl >= 5)
		dat += {"
<B>Security Level Elevated</B><BR>
<BR>
<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A><BR>
<BR>
<B>Coder Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsadmin=list_job_debug'>Show Job Debug</A><BR>
<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
<BR>
"}
	usr << browse(dat, "window=secrets")
	return

/obj/admins/proc/Voting()

	var/dat
	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Temporary Admin")
			lvl = 2
		if("Admin Candidate")
			lvl = 3
		if("Trial Admin")
			lvl = 4
		if("Badmin")
			lvl = 5
		if("Game Admin")
			lvl = 6
		if("Game Master")
			lvl = 7


	dat += "<center><B>Voting</B></center><hr>\n"

	if(lvl > 0)
//			if(lvl >= 2 )
		dat += {"
<A href='?src=\ref[src];votekill=1'>Abort Vote</A><br>
<A href='?src=\ref[src];vmode=1'>Start Vote</A><br>
<A href='?src=\ref[src];voteres=1'>Toggle Voting</A><br>
"}

//			if(lvl >= 3 )
//			if(lvl >= 5)
//			if(lvl == 6 )

	usr << browse(dat, "window=admin2;size=210x160")
	return



/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/obj/admins/proc/vmode()
	set category = "Server"
	set name = "Start Vote"
	set desc="Starts vote"
	if (!usr.client.holder)
		return
	var/confirm = alert("What vote would you like to start?", "Vote", "Restart", "Change Game Mode", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Restart")
		vote.mode = 0
	// hack to yield 0=restart, 1=changemode
	if(confirm == "Change Game Mode")
		vote.mode = 1
		if(!ticker)
			if(going)
				world << "<B>The game start has been delayed.</B>"
				going = 0
	vote.voting = 1
						// now voting
	vote.votetime = world.timeofday + config.vote_period*10
	// when the vote will end
	spawn(config.vote_period*10)
		vote.endvote()
	world << "\red<B>*** A vote to [vote.mode?"change game mode":"restart"] has been initiated by Admin [usr.key].</B>"
	world << "\red     You have [vote.timetext(config.vote_period)] to vote."

	log_admin("Voting to [vote.mode?"change mode":"restart round"] forced by admin [key_name(usr)]")

	for(var/mob/CM in player_list)
		if(config.vote_no_default || (config.vote_no_dead && CM.stat == 2))
			CM.client.vote = "none"
		else
			CM.client.vote = "default"

	for(var/mob/CM in player_list)
		if(config.vote_no_default || (config.vote_no_dead && CM.stat == 2))
			CM.client.vote = "none"
		else
			CM.client.vote = "default"
	feedback_add_details("admin_verb","SV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/votekill()
	set category = "Server"
	set name = "Abort Vote"
	set desc="Aborts a vote"
	if(vote.voting == 0)
		alert("No votes in progress")
		return
	world << "\red <b>*** Voting aborted by [usr.client.stealth ? "Admin Candidate" : usr.key].</b>"

	log_admin("Voting aborted by [key_name(usr)]")

	vote.voting = 0
	vote.nextvotetime = world.timeofday + 10*config.vote_delay

	for(var/mob/M in player_list)
		// clear vote window from all clients
		M << browse(null, "window=vote")
		M.client.showvote = 0
	feedback_add_details("admin_verb","AV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/voteres()
	set category = "Server"
	set name = "Toggle Voting"
	set desc="Toggles Votes"
	var/confirm = alert("What vote would you like to toggle?", "Vote", "Restart [config.allow_vote_restart ? "Off" : "On"]", "Change Game Mode [config.allow_vote_mode ? "Off" : "On"]", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Restart [config.allow_vote_restart ? "Off" : "On"]")
		config.allow_vote_restart = !config.allow_vote_restart
		world << "<b>Player restart voting toggled to [config.allow_vote_restart ? "On" : "Off"]</b>."
		log_admin("Restart voting toggled to [config.allow_vote_restart ? "On" : "Off"] by [key_name(usr)].")

		if(config.allow_vote_restart)
			vote.nextvotetime = world.timeofday
	if(confirm == "Change Game Mode [config.allow_vote_mode ? "Off" : "On"]")
		config.allow_vote_mode = !config.allow_vote_mode
		world << "<b>Player mode voting toggled to [config.allow_vote_mode ? "On" : "Off"]</b>."
		log_admin("Mode voting toggled to [config.allow_vote_mode ? "On" : "Off"] by [key_name(usr)].")

		if(config.allow_vote_mode)
			vote.nextvotetime = world.timeofday
	feedback_add_details("admin_verb","TV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		world << "\red <b>Restarting world!</b> \blue Initiated by [usr.client.stealth ? "Admin" : usr.key]!"
		log_admin("[key_name(usr)] initiated a reboot.")

		feedback_set_details("end_error","admin reboot - by [usr.key] [usr.client.stealth ? "(stealth)" : ""]")
		feedback_add_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		if(blackbox)
			blackbox.save_all_data_to_sql()

		sleep(50)
		world.Reboot()


/obj/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Game Admin" && usr.client.holder.rank != "Game Master")
			message = adminscrub(message,500)
		world << "\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Announces:</b>\n \t [message]"
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggleooc()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.", 1)
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		log_admin("[usr.key] has started the game.")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		usr << "<font color='red'>Error: Start Now: Game has already started.</font>"
		return 0

/obj/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		world << "<B>New players may no longer enter the game.</B>"
	else
		world << "<B>New players may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("\blue [key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		world << "<B>The AI job is no longer chooseable.</B>"
	else
		world << "<B>The AI job is chooseable now.</B>"
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		world << "<B>You may now respawn.</B>"
	else
		world << "<B>You may no longer respawn :(</B>"
	message_admins("\blue [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	aliens_allowed = !aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [aliens_allowed ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggle_space_ninja()
	set category = "Server"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	toggle_space_ninja = !toggle_space_ninja
	log_admin("[key_name(usr)] toggled Space Ninjas to [toggle_space_ninja].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [toggle_space_ninja ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start"
	set name="Delay"
	if (!ticker || ticker.current_state != GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!", null, null, null, null, null)
	going = !( going )
	if (!( going ))
		world << "<b>The game start has been delayed.</b>"
		log_admin("[key_name(usr)] delayed the game.")
	else
		world << "<b>The game will start soon.</b>"
		log_admin("[key_name(usr)] removed the delay.")
	feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("\blue Toggled admin jumping to [config.allow_admin_jump].")
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("\blue Toggled admin item spawning to [config.allow_admin_spawning].")
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("\blue Toggled reviving to [config.allow_admin_rev].")
	feedback_add_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	world << "\red <b>Rebooting world!</b> \blue Initiated by [usr.client.stealth ? "Admin" : usr.key]!"
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.stealth ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot()

/client/proc/deadchat()
	set category = "Admin"
	set desc="Toggles Deadchat Visibility"
	set name="Deadchat Visibility"
	if(deadchat == 0)
		deadchat = 1
		usr << "Deadchat turned on"
	else
		deadchat = 0
		usr << "Deadchat turned off"
	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set category = "Admin"
	set desc="Toggles Prayer Visibility"
	set name="Prayer Visibility"
	if(seeprayers == 0)
		seeprayers = 1
		usr << "Prayer visibility turned on"
	else
		seeprayers = 0
		usr << "Prayer visibility turned off"
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/unprison(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == 2)
		if (config.allow_admin_jump)
			M.loc = pick(latejoin)
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(mob/M as mob) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!ticker || !ticker.mode)
		return 0
	if (!istype(M))
		return 0
	if((M.mind in ticker.mode.head_revolutionaries) || (M.mind in ticker.mode.revolutionaries))
		if (ticker.mode.config_tag == "revolution")
			return 2
		return 1
	if(M.mind in ticker.mode.cult)
		if (ticker.mode.config_tag == "cult")
			return 2
		return 1
	if(M.mind in ticker.mode.malf_ai)
		if (ticker.mode.config_tag == "malfunction")
			return 2
		return 1
	if(M.mind in ticker.mode.syndicates)
		if (ticker.mode.config_tag == "nuclear")
			return 2
		return 1
	if(M.mind in ticker.mode.wizards)
		if (ticker.mode.config_tag == "wizard")
			return 2
		return 1
	if(M.mind in ticker.mode.changelings)
		if (ticker.mode.config_tag == "changeling")
			return 2
		return 1

	for(var/datum/disease/D in M.viruses)
		if(istype(D, /datum/disease/jungle_fever))
			if (ticker.mode.config_tag == "monkey")
				return 2
			return 1
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return 1
	if(M.mind&&M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return 1

	return 0

/*
/obj/admins/proc/get_sab_desc(var/target)
	switch(target)
		if(1)
			return "Destroy at least 70% of the plasma canisters on the station"
		if(2)
			return "Destroy the AI"
		if(3)
			var/count = 0
			for(var/mob/living/carbon/monkey/Monkey in world)
				if(Monkey.z == 1)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"
*/
/obj/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set desc= "(atom path) Spawn an atom"
	set name= "Spawn"

	if(usr.client.holder.level >= 5)
		var/list/types = typesof(/atom)

		var/list/matches = new()

		for(var/path in types)
			if(findtext("[path]", object))
				matches += path

		if(matches.len==0)
			return

		var/chosen
		if(matches.len==1)
			chosen = matches[1]
		else
			chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
			if(!chosen)
				return

		new chosen(usr.loc)

		log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/obj/admins/proc/show_traitor_panel(var/mob/M in mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if (!M.mind)
		usr << "Sorry, this mob has no mind!"
		return
	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/obj/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	tinted_weldhelh = !( tinted_weldhelh )
	if (tinted_weldhelh)
		world << "<B>The tinted_weldhelh has been enabled!</B>"
	else
		world << "<B>The tinted_weldhelh has been disabled!</B>"
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.", 1)
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	guests_allowed = !( guests_allowed )
	if (!( guests_allowed ))
		world << "<B>Guests may no longer enter the game.</B>"
	else
		world << "<B>Guests may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	message_admins("\blue [key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.", 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unjobban_panel()
	set name = "Unjobban Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.unjobbanpanel()
	feedback_add_details("admin_verb","UJBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/obj/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in mob_list)
		ai_number++
		if(isAI(S))
			usr << "<b>AI [key_name(S, usr)]'s laws:</b>"
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			usr << "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>"
		else if (ispAI(S))
			usr << "<b>pAI [key_name(S, usr)]'s laws:</b>"
		else
			usr << "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>"

		if (S.laws == null)
			usr << "[key_name(S, usr)]'s laws are null?? Contact a coder."
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		usr << "<b>No AIs located</b>" //Just so you know the thing is actually working and not just ignoring you.

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//


/**********************Administration Shuttle**************************/

var/admin_shuttle_location = 0 // 0 = centcom 13, 1 = station

proc/move_admin_shuttle()
	var/area/fromArea
	var/area/toArea
	if (admin_shuttle_location == 1)
		fromArea = locate(/area/shuttle/administration/station)
		toArea = locate(/area/shuttle/administration/centcom)
	else
		fromArea = locate(/area/shuttle/administration/centcom)
		toArea = locate(/area/shuttle/administration/station)
	fromArea.move_contents_to(toArea)
	if (admin_shuttle_location)
		admin_shuttle_location = 0
	else
		admin_shuttle_location = 1
	return

/**********************Centcom Ferry**************************/

var/ferry_location = 0 // 0 = centcom , 1 = station

proc/move_ferry()
	var/area/fromArea
	var/area/toArea
	if (ferry_location == 1)
		fromArea = locate(/area/shuttle/transport1/station)
		toArea = locate(/area/shuttle/transport1/centcom)
	else
		fromArea = locate(/area/shuttle/transport1/centcom)
		toArea = locate(/area/shuttle/transport1/station)
	fromArea.move_contents_to(toArea)
	if (ferry_location)
		ferry_location = 0
	else
		ferry_location = 1
	return

/**********************Alien ship**************************/

var/alien_ship_location = 1 // 0 = base , 1 = mine

proc/move_alien_ship()
	var/area/fromArea
	var/area/toArea
	if (alien_ship_location == 1)
		fromArea = locate(/area/shuttle/alien/mine)
		toArea = locate(/area/shuttle/alien/base)
	else
		fromArea = locate(/area/shuttle/alien/base)
		toArea = locate(/area/shuttle/alien/mine)
	fromArea.move_contents_to(toArea)
	if (alien_ship_location)
		alien_ship_location = 0
	else
		alien_ship_location = 1
	return