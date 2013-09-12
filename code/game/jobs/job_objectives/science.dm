// MAXIMUM SCIENCE
/datum/job_objective/maximize_research
	completion_payment=1000

/datum/job_objective/maximize_research/get_description()
	return "Maximize all legal research tech levels."

/datum/job_objective/maximize_research/check_for_completion()
	var/obj/machinery/r_n_d/server/server = locate(/obj/machinery/r_n_d/server) in /area/toxins/server
	for(var/datum/tech/T in server.files.possible_tech)
		if(T.max_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT  = locate(T.type, server.files.known_tech)
		if(!KT)
			return 0 // Obviously haven't maxed everything if we don't know a tech.
		if(KT.level<T.max_level)
			return 0
	return 1
