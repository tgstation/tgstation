//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/card
	name = "identification console"
	desc = "You can use this to change ID's."
	icon_state = "id"
	req_access = list(access_change_ids)
	circuit = /obj/item/weapon/circuitboard/card
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/modify = null
	var/authenticated = 0.0
	var/mode = 0.0
	var/printing = null
	var/edit_job_target = ""

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 280
	//Keeps track of the time
	var/time_last_changed_position = 0
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
		"AI",
		"Assistant",
		"Cyborg",
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Warden",
		"Chief Engineer",
		"Quartermaster",
		"Research Director",
		"Chief Medical Officer",
		"Chaplain")

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list();

/obj/machinery/computer/card/attackby(O as obj, user as mob)//TODO:SANITY
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = O
		if(access_change_ids in idcard.access)
			if(!scan)
				usr.drop_item()
				idcard.loc = src
				scan = idcard
			else if(!modify)
				usr.drop_item()
				idcard.loc = src
				modify = idcard
		else
			if(!modify)
				usr.drop_item()
				idcard.loc = src
				modify = idcard
	else
		..()

//Check if you can't open a new position for a certain job
/obj/machinery/computer/card/proc/job_blacklisted(jobtitle)
	return (jobtitle in blacklisted)


//Logic check for Topic() if you can open the job
/obj/machinery/computer/card/proc/can_open_job(var/datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if((job.total_positions <= player_list.len * (max_relative_positions / 100)))
				var/delta = (world.time / 10) - time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] < 0))
					return 1
				return -2
			return -1
	return 0

//Logic check for Topic() if you can close the job
/obj/machinery/computer/card/proc/can_close_job(var/datum/job/job)
	if(job)
		if(!job_blacklisted(job.title))
			if(job.total_positions > job.current_positions)
				var/delta = (world.time / 10) - time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] > 0))
					return 1
				return -2
			return -1
	return 0

/obj/machinery/computer/card/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_machine(src)
	var/dat
	if(!ticker)	return
	if (mode == 1) // accessing crew manifest
		var/crew = ""
		for(var/datum/data/record/t in sortRecord(data_core.general))
			crew += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
		dat = "<tt><b>Crew Manifest:</b><br>Please use security record computer to modify entries.<br><br>[crew]<a href='?src=\ref[src];choice=print'>Print</a><br><br><a href='?src=\ref[src];choice=mode;mode_target=0'>Access ID modification console.</a><br></tt>"

	else if(mode == 2)
		// JOB MANAGEMENT
		var/datum/job/j = job_master.GetJob(edit_job_target)
		if(!j)
		// SHOW MAIN JOB MANAGEMENT MENU
			dat = "<a href='?src=\ref[src];choice=return'><i>Return</i></a><hr>"
			dat += "<h1>Job Management</h1>"
			dat += "<i>Choose Job</i><hr>"
			for(var/datum/job/job in job_master.occupations)
				if(!(job.title in blacklisted))
					dat += "<a href='?src=\ref[src];choice=edit_job;job=[job.title]'><b>[job.title]</b></a> ([job.current_positions]/[job.total_positions])<br>"
		else
			if(check_access(scan))
			// EDIT SPECIFIC JOB
				dat = "<a href='?src=\ref[src];choice=return'><i>Return</i></a><hr>"
				dat += "<h1>[j.title]: [j.current_positions]/[j.total_positions]</h1><hr>"
				//Make sure antags can't completely ruin rounds

				//Don't allow more than 1 Head / limit blacklisted jobs
				switch(can_open_job(j))
					if(1)
						dat += "<a href='?src=\ref[src];choice=make_job_available'>Open Position</a><br>"
					if(-1)
						dat += "<b>You cannot open any more positions for this job.</b><br>"
					if(-2)
						var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - time_last_changed_position), 1)
						var/mins = round(time_to_wait / 60)
						var/seconds = time_to_wait - (60*mins)
						dat += "<b>You have to wait [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"] minutes before you can open this position.</b>"
					if(0)
						dat += "<b>You cannot open positions for this job.</b><br>"


				switch(can_close_job(j))
					if(1)
						dat += "<a href='?src=\ref[src];choice=make_job_unavailable'>Close Position</a>"
					if(-1)
						dat += "<b>You cannot close any more positions for this job.</b><br>"
					if(-2)
						var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - time_last_changed_position), 1)
						var/mins = round(time_to_wait / 60)
						var/seconds = time_to_wait - (60*mins)
						dat += "<b>You have to wait [mins]:[(seconds < 10) ? "0[seconds]" : "[seconds]"] minutes before you can close this position.</b>"
					if(0)
						dat += "<b>You cannot close positions for this job.</b><br>"
			else
				dat = "<a href='?src=\ref[src];choice=return'><i>Return</i></a><hr>"
				dat += "<h1>Please insert your ID</h1>"
				mode = 3

	else
		var/header = ""

		var/target_name
		var/target_owner
		var/target_rank
		if(modify)
			target_name = modify.name
		else
			target_name = "--------"
		if(modify && modify.registered_name)
			target_owner = modify.registered_name
		else
			target_owner = "--------"
		if(modify && modify.assignment)
			target_rank = modify.assignment
		else
			target_rank = "Unassigned"

		var/scan_name
		if(scan)
			scan_name = scan.name
		else
			scan_name = "--------"

		if(!authenticated)
			header += "<br><i>Please insert the cards into the slots</i><br>"
			header += "Target: <a href='?src=\ref[src];choice=modify'>[target_name]</a><br>"
			header += "Confirm Identity: <a href='?src=\ref[src];choice=scan'>[scan_name]</a><br>"
		else
			header += "<div align='center'><br>"
			header += "<a href='?src=\ref[src];choice=modify'>Remove [target_name]</a> || "
			header += "<a href='?src=\ref[src];choice=scan'>Remove [scan_name]</a> <br> "
			header += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a> || "
			header += "<a href='?src=\ref[src];choice=logout'>Log Out</a></div>"

		header += "<hr>"

		var/jobs_all = ""
		var/list/alljobs = (istype(src,/obj/machinery/computer/card/centcom)? get_all_centcom_jobs() : get_all_jobs()) + "Custom"
		for(var/job in alljobs)
			jobs_all += "<a href='?src=\ref[src];choice=assign;assign_target=[job]'>[replacetext(job, " ", "&nbsp")]</a> " //make sure there isn't a line break in the middle of a job


		var/body
		if (authenticated && modify)
			var/carddesc = {"<script type="text/javascript">
								function markRed(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#FFDDDD";
								}
								function markGreen(){
									var nameField = document.getElementById('namefield');
									nameField.style.backgroundColor = "#DDFFDD";
								}
								function showAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='hideAll()'>hide</a><br>"+ "[jobs_all]";
								}
								function hideAll(){
									var allJobsSlot = document.getElementById('alljobsslot');
									allJobsSlot.innerHTML = "<a href='#' onclick='showAll()'>show</a>";
								}
							</script>"}
			carddesc += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
			carddesc += "<input type='hidden' name='src' value='\ref[src]'>"
			carddesc += "<input type='hidden' name='choice' value='reg'>"
			carddesc += "<b>registered_name:</b> <input type='text' id='namefield' name='reg' value='[target_owner]' style='width:250px; background-color:white;' onchange='markRed()'>"
			carddesc += "<input type='submit' value='Rename' onclick='markGreen()'>"
			carddesc += "</form>"
			carddesc += "<b>Assignment:</b> "

			var/jobs = "<span id='alljobsslot'><a href='#' onclick='showAll()'>[target_rank]</a></span>" //CHECK THIS

			var/accesses = ""
			if(istype(src,/obj/machinery/computer/card/centcom))
				accesses += "<h5>Central Command:</h5>"
				for(var/A in get_all_centcom_access())
					if(A in modify.access)
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</font></a> "
					else
						accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[replacetext(get_centcom_access_desc(A), " ", "&nbsp")]</a> "
			else
				accesses += "<div align='center'><b>Access</b></div>"
				accesses += "<table style='width:100%'>"
				accesses += "<tr>"
				for(var/i = 1; i <= 7; i++)
					accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
				accesses += "</tr><tr>"
				for(var/i = 1; i <= 7; i++)
					accesses += "<td style='width:14%' valign='top'>"
					for(var/A in get_region_accesses(i))
						if(A in modify.access)
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=0'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
						else
							accesses += "<a href='?src=\ref[src];choice=access;access_target=[A];allowed=1'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
						accesses += "<br>"
					accesses += "</td>"
				accesses += "</tr></table>"
			body = "[carddesc]<br>[jobs]<br><br>[accesses]" //CHECK THIS
		else
			body = "<a href='?src=\ref[src];choice=auth'>{Log in}</a> <br><hr>"
			body += "<a href='?src=\ref[src];choice=mode;mode_target=1'>Access Crew Manifest</a>"
			body += "<br><hr><a href = '?src=\ref[src];choice=mode;mode_target=2'>Job Management</a>"

		dat = "<tt>[header][body]<hr><br></tt>"

	//user << browse(dat, "window=id_com;size=900x520")
	//onclose(user, "id_com")

	var/datum/browser/popup = new(user, "id_com", "Identification Card Modifier Console", 900, 590)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return


/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["choice"])
		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				modify.loc = loc
				modify.verb_pickup()
				modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					modify = I
			authenticated = 0

		if ("scan")
			if (scan)
				scan.loc = src.loc
				scan.verb_pickup()
				scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					scan = I
			authenticated = 0
		if ("auth")
			if ((!( authenticated ) && (scan || (istype(usr, /mob/living/silicon))) && (modify || mode)))
				if (check_access(scan))
					authenticated = 1
			else if ((!( authenticated ) && (istype(usr, /mob/living/silicon))) && (!modify))
				usr << "You can't modify an ID without an ID inserted to modify. Once one is in the modify slot on the computer, you can log in."
		if ("logout")
			authenticated = 0
		if("access")
			if(href_list["allowed"])
				if(authenticated)
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (istype(src,/obj/machinery/computer/card/centcom)?get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(access_allowed == 1)
							modify.access += access_type
		if ("assign")
			if (authenticated)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = copytext(sanitize(input("Enter a custom job assignment.","Assignment")),1,MAX_NAME_LEN)
					if(temp_t)
						t1 = temp_t
				else
					var/datum/job/jobdatum
					for(var/jobtype in typesof(/datum/job))
						var/datum/job/J = new jobtype
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							break
					if(!jobdatum)
						usr << "\red No log exists for this job."
						return

					modify.access = ( istype(src,/obj/machinery/computer/card/centcom) ? get_centcom_access(t1) : jobdatum.get_access() )
				if (modify)
					modify.assignment = t1
		if ("reg")
			if (authenticated)
				var/t2 = modify
				//var/t1 = input(usr, "What name?", "ID computer", null)  as text
				if ((authenticated && modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					modify.registered_name = copytext(sanitize(href_list["reg"]),1,MAX_NAME_LEN)
		if ("mode")
			mode = text2num(href_list["mode_target"])

		if("edit_job")
			edit_job_target = href_list["job"]
			if(job_master.GetJob(edit_job_target) == null)
				edit_job_target = ""

		if("return")
			if(edit_job_target != "")
				//RETURN TO JOB MANAGEMENT
				edit_job_target = ""
			else
				//DISPLAY MAIN MENU
				mode = 3;
				edit_job_target = ""

		if("make_job_available")
			// MAKE ANOTHER JOB POSITION AVAILABLE FOR LATE JOINERS
			var/datum/job/j = job_master.GetJob(edit_job_target)
			if(!j)
				return 0
			if(can_open_job(j) != 1)
				return 0
			if(opened_positions[edit_job_target] >= 0)
				time_last_changed_position = world.time / 10
			j.total_positions++
			opened_positions[edit_job_target]++

		if("make_job_unavailable")
			// MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			var/datum/job/j = job_master.GetJob(edit_job_target)
			if(!j)
				return 0
			if(can_close_job(j) != 1)
				return 0
			//Allow instant closing without cooldown if a position has been opened before
			if(opened_positions[edit_job_target] <= 0)
				time_last_changed_position = world.time / 10
			j.total_positions--
			opened_positions[edit_job_target]--

		if ("print")
			if (!( printing ))
				printing = 1
				sleep(50)
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
				var/t1 = "<B>Crew Manifest:</B><BR>"
				for(var/datum/data/record/t in sortRecord(data_core.general))
					t1 += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
				P.info = t1
				P.name = "paper- 'Crew Manifest'"
				printing = null
	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
	updateUsrDialog()
	return



/obj/machinery/computer/card/centcom
	name = "\improper Centcom identification console"
	circuit = /obj/item/weapon/circuitboard/card/centcom
	req_access = list(access_cent_captain)

