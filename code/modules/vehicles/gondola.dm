GLOBAL_LIST_EMPTY(gondola_route_checkpoint)

/obj/vehicle/ridden/gondola
	name = "Gondola"
	desc = "Well it ain't Venice"
	icon = 'icons/obj/gondola.dmi'
	icon_state = "gondolaboat"
	max_integrity = 9999
	var/current_checkpoint = 1
	var/list/sacrifice = list() //sacrifical list we sacrifice to the array gods

/obj/vehicle/ridden/gondola/Initialize()
	. = ..()
	addtimer(CALLBACK(src,.proc/continue_route,5 SECONDS))


/obj/vehicle/ridden/gondola/proc/continue_route()
	var/list/checkpoints = GLOB.gondola_route_checkpoint
	if(!checkpoints.len)
		stack_trace("Checkpoint list is empty! Gondola ride cannot commence.")
		return
	for(var/obj/effect/landmark/gondola/G in checkpoints)
		if(current_checkpoint == G.checkpoint)
			walk_towards(src,G.loc,5)
			var/i = 1
			while(G.loc != src.loc || i < 5)
				sleep(5 SECONDS)
				i++
			if(prob(25))
				to_chat(src,"[pick("ohh fuggggg","benis :D :D:D:D","hello :DD:: fren","oh fug :D we go this way now")]")
			++current_checkpoint
		if(current_checkpoint == (checkpoints.len + 1))
			current_checkpoint = 1
	continue_route()

/obj/vehicle/ridden/gondola/driver_move(mob/user, direction)
	return



/obj/effect/landmark/gondola/
	var/checkpoint = 1

/obj/effect/landmark/gondola/Initialize()
	. = ..()
	GLOB.gondola_route_checkpoint += src
	

