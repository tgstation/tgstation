GLOBAL_DATUM(main_clock_cult, /datum/team/clock_cult) //gets refed a decent amount and its impossible to create a second one so im making this a global var

/datum/team/clock_cult
	name = "Clock Cult"

/datum/team/clock_cult/proc/setup_objectives()
	if(objectives.len)
		return
	GLOB.main_clock_cult = src
	return
