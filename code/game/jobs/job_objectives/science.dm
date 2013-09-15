// MAXIMUM SCIENCE
/datum/job_objective/maximize_research
	completion_payment=1000

/datum/job_objective/maximize_research/get_description()
	return "Maximize all legal research tech levels."

/datum/job_objective/maximize_research/check_for_completion()
	var/obj/machinery/r_n_d/server/server = null
	for(var/obj/machinery/r_n_d/server/serber in machines)
		if(serber.name == "Core R&D Server")
			server=serber
			break
	if(!server)
		// This was just used for testing.
		//world << "UNABLE TO FIND A GODDAMN RND SERVER. FUCK."
		return
	for(var/datum/tech/T in server.files.possible_tech)
		if(T.max_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT  = locate(T.type, server.files.known_tech)
		if(!KT)
			return 0 // Obviously haven't maxed everything if we don't know a tech.
		if(KT.level<T.max_level)
			return 0
	return 1
