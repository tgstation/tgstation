/mob/living/carbon/alien/verb/ventcrawl() // -- TLE
	set name = "Crawl Through Vent (Alien)"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/unary/U in range(1))
		if((istype(U, /obj/machinery/atmospherics/unary/vent_pump) || istype(U,/obj/machinery/atmospherics/unary/vent_scrubber)) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(pipe)
		handle_ventcrawl(pipe)
	handle_ventcrawl(pipe)