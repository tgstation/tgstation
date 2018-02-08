/mob/living/carbon/human/lobby/proc/LateChoices()
	//we are being allowed to join, time to disappear
	PhaseInSplashScreen()

	var/dat = "<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>"

	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div class='notice red'>The station has been evacuated.</div><br>"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"

	var/available_job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			available_job_count++

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	if(length(SSjob.prioritized_jobs))
		dat += "<div class='notice red'>The station has flagged these jobs as high priority:<br>"
		var/amt = length(SSjob.prioritized_jobs)
		var/amt_count
		for(var/datum/job/a in SSjob.prioritized_jobs)
			amt_count++
			if(amt_count != amt) // checks for the last job added.
				dat += " [a.title], "
			else
				dat += " [a.title]. </div>"

	dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
	dat += "<div class='jobs'><div class='jobsColumn'>"
	var/job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			job_count++
			if (job_count > round(available_job_count / 2))
				dat += "</div><div class='jobsColumn'>"
			var/position_class = "otherPosition"
			if (job.title in GLOB.command_positions)
				position_class = "commandPosition"
			dat += "<a class='[position_class]' href='byond://?src=[REF(src)];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
	if(!job_count) //if there's nowhere to go, assistant opens up.
		for(var/datum/job/job in SSjob.occupations)
			if(job.title != "Assistant")
				continue
			dat += "<a class='otherPosition' href='byond://?src=[REF(src)];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			break
	dat += "</div></div>"

	// Added the new browser window method
	late_picker = new(src, "latechoices", "Choose Profession", 440, 500, src)
	late_picker.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	late_picker.set_content(dat)
	late_picker.open(TRUE)

/mob/living/carbon/human/lobby/Topic(href, list/href_list)
	if(src != usr)
		return

	//only the latespawn window does this
	if(href_list["close"])
		if(!QDELETED(src) && !new_character)
			//still around, they just closed the window
			MoveToStartArea(TRUE)
			PhaseOutSplashScreen()
			late_join.Grant(src)
			invisibility = 0
		return

	if(href_list["SelectedJob"])
		if(!GLOB.enter_allowed)
			to_chat(src, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		else if(SSticker.queued_players.len && !(ckey in GLOB.admin_datums) && ((living_player_count() >= GetRelevantCap()) || (src != SSticker.queued_players[1])))
			to_chat(src, "<span class='warning'>Server is full.</span>")
		else
			AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(href_list["preference"])
		client.prefs.process_link(src, href_list)

	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["pollid"])
		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid) && ISINTEGER(pollid))
			poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		//lets take data from the user to decide what kind of poll this is, without validating it
		//what could go wrong
		switch(votetype)
			if(POLLTYPE_OPTION)
				var/optionid = text2num(href_list["voteoptionid"])
				if(vote_on_poll(pollid, optionid))
					to_chat(usr, "<span class='notice'>Vote successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_TEXT)
				var/replytext = href_list["replytext"]
				if(log_text_poll_reply(pollid, replytext))
					to_chat(usr, "<span class='notice'>Feedback logging successful.</span>")
				else
					to_chat(usr, "<span class='danger'>Feedback logging failed, please try again or contact an administrator.</span>")
			if(POLLTYPE_RATING)
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
												//(protip, this stops no exploits)
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating) || !ISINTEGER(rating))
								return

						if(!vote_on_numval_poll(pollid, optionid, rating))
							to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
							return
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_MULTI)
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					to_chat(usr, "The option ID difference is too big. Please contact administration or the database admin.")
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						var/i = vote_on_multi_poll(pollid, optionid)
						switch(i)
							if(0)
								continue
							if(1)
								to_chat(usr, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
								return
							if(2)
								to_chat(usr, "<span class='danger'>Maximum replies reached.</span>")
								break
				to_chat(usr, "<span class='notice'>Vote successful.</span>")
			if(POLLTYPE_IRV)
				if (!href_list["IRVdata"])
					to_chat(src, "<span class='danger'>No ordering data found. Please try again or contact an administrator.</span>")
				var/list/votelist = splittext(href_list["IRVdata"], ",")
				if (!vote_on_irv_poll(pollid, votelist))
					to_chat(src, "<span class='danger'>Vote failed, please try again or contact an administrator.</span>")
					return
				to_chat(src, "<span class='notice'>Vote successful.</span>")
