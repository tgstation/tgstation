GLOBAL_LIST_EMPTY(gondola_route_checkpoint)

/obj/vehicle/ridden/gondola
	name = "Gondola"
	desc = "Well it ain't Venice"
	icon = 'icons/obj/gondola.dmi'
	icon_state = "gondolaboat"
	max_integrity = 9999
	var/current_checkpoint = 1
	var/list/sacrifice = list() //sacrifical list we sacrifice to the array gods
	var/list/checkpoints

/obj/vehicle/ridden/gondola/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD


/obj/vehicle/ridden/gondola/LateInitialize()
	. = ..()
	checkpoints = GLOB.gondola_route_checkpoint
	continue_route()


/obj/vehicle/ridden/gondola/proc/continue_route()
	if(!checkpoints.len)
		stack_trace("Checkpoint list is empty! Gondola ride cannot commence.")
		return
	for(var/obj/effect/landmark/gondola/G in checkpoints)
		if(current_checkpoint == G.checkpoint)
			walk_towards(src,G.loc,3)
			addtimer(CALLBACK(src,.proc/check_pos, G),5 SECONDS)
			if(prob(25))
				var/word = pick("ohh fuggggg","benis :D :D:D:D","hello :DD:: fren","oh fug :D we go this way now","ebin :D")
				src.say(word)

/obj/vehicle/ridden/gondola/proc/check_pos(obj/effect/landmark/gondola/G)
	if(G.loc != src.loc)
		addtimer(CALLBACK(src,.proc/check_pos, G),5 SECONDS)
	else
		++current_checkpoint
		if(current_checkpoint > checkpoints.len)
			current_checkpoint = 1
		continue_route()

/obj/vehicle/ridden/gondola/driver_move(mob/user, direction)
	return



/obj/effect/landmark/gondola/
	var/checkpoint = 1

/obj/effect/landmark/gondola/Initialize()
	. = ..()
	GLOB.gondola_route_checkpoint += src
	

