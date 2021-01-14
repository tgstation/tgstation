/datum/round_event_control/wizard/deprevolt //stationwide!
	name = "Departmental Uprising"
	weight = 0 //An order that requires order in a round of chaos was maybe not the best idea. Requiescat in pace departmental uprising August 2014 - March 2015
	typepath = /datum/round_event/wizard/deprevolt
	max_occurrences = 1
	earliest_start = 0 MINUTES

	var/picked_department
	var/announce = FALSE

/datum/round_event_control/wizard/deprevolt/admin_setup()
	if(!check_rights(R_FUN))
		return
	var/list/options = list("Random", "Uprising of Assistants", "Medical", "Engineering", "Science", "Cargo", "Service", "Security")
	picked_department = input(usr,"Which department should revolt?","Select a department") as null|anything in options

	//if they cancel just do the event as if it wasn't with admin intervention
	if(!picked_department)
		return

	if(picked_department == "Random")
		picked_department = pick(options - "Random")

	var/question = alert(usr, "Announce This New Independent State?", "Secession", "Announce", "No Announcement")
	if(question == "Announce")
		announce = TRUE

/datum/round_event/wizard/deprevolt/start()

	var/datum/round_event_control/wizard/deprevolt/C = control

	var/announcement = FALSE
	var/department
	if(C.announce)
		announcement = TRUE
	if(C.picked_department)
		department = C.picked_department
		C.picked_department = null
	else
		department = pick(list("Uprising of Assistants", "Medical", "Engineering", "Science", "Cargo", "Service", "Security"))
	var/list/jobs_to_revolt	= list()
	var/nation_name
	var/list/citizens = list()

	switch(department)
		if("Uprising of Assistants") //God help you
			jobs_to_revolt = list("Assistant")
			nation_name = pick("Assa", "Mainte", "Tunnel", "Gris", "Grey", "Liath", "Grigio", "Ass", "Assi")
		if("Medical")
			jobs_to_revolt = GLOB.medical_positions
			nation_name = pick("Mede", "Healtha", "Recova", "Chemi", "Viro", "Psych")
		if("Engineering")
			jobs_to_revolt = GLOB.engineering_positions
			nation_name = pick("Atomo", "Engino", "Power", "Teleco")
		if("Science")
			jobs_to_revolt = GLOB.science_positions
			nation_name = pick("Sci", "Griffa", "Geneti", "Explosi", "Mecha", "Xeno")
		if("Supply")
			jobs_to_revolt = GLOB.supply_positions
			nation_name = pick("Cargo", "Guna", "Suppli", "Mule", "Crate", "Ore", "Mini", "Shaf")
		if("Service") //the few, the proud, the technically aligned
			jobs_to_revolt = GLOB.service_positions.Copy() - list("Assistant", "Prisoner")
			nation_name = pick("Honka", "Boozo", "Fatu", "Danka", "Mimi", "Libra", "Jani", "Religi")
		if("Security")
			jobs_to_revolt = GLOB.security_positions
			nation_name = pick("Securi", "Beepski", "Shitcuri", "Red", "Stunba", "Flashbango", "Flasha", "Stanfordi")

	nation_name += pick("stan", "topia", "land", "nia", "ca", "tova", "dor", "ador", "tia", "sia", "ano", "tica", "tide", "cis", "marea", "co", "taoide", "slavia", "stotzka")

	var/datum/team/nation/nation = new(null, jobs_to_revolt)
	nation.name = nation_name

	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		if(H.mind)
			var/datum/mind/M = H.mind
			if(M.assigned_role && !(M.has_antag_datum(/datum/antagonist)))
				for(var/job in jobs_to_revolt)
					if(M.assigned_role == job)
						citizens += H
						M.add_antag_datum(/datum/antagonist/separatist,nation)
						H.log_message("Was made into a separatist, long live [nation_name]!", LOG_ATTACK, color="red")

	if(citizens.len)
		var/jobs_english_list = english_list(jobs_to_revolt)
		message_admins("The nation of [nation_name] has been formed. Affected jobs are [jobs_english_list]. Any new crewmembers with these jobs will join the secession.")
		if(announcement)
			var/announce_text = "The new independent state of [nation_name] has formed from the ashes of the [department] department!"
			if(department == "Uprising of Assistants") //the text didn't really work otherwise
				announce_text = "The assistants of the station have risen to form the new independent state of [nation_name]!"
			priority_announce(announce_text, "Secession from [GLOB.station_name]")
	else
		message_admins("The nation of [nation_name] did not have enough potential members to be created.")
		qdel(nation)
