/obj/machinery/atmospherics/unary/vent/burstpipe
	icon = 'icons/obj/pipes.dmi'
	icon_state = "burst"
	name = "burst pipe"
	desc = "A section of burst piping.  Leaks like a sieve."
	//level = 1
	volume = 1000 // large volume
	dir = SOUTH
	initialize_directions = SOUTH

/obj/machinery/atmospherics/unary/vent/burstpipe/New(var/_loc, var/setdir=SOUTH)
	// Easier spawning.
	dir=setdir
	..(_loc)

/obj/machinery/atmospherics/unary/vent/burstpipe/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/unary/vent/burstpipe/update_icon()
	alpha = invisibility ? 128 : 255
	if(!node || istype(node,type)) // No connection, or the connection is another burst pipe
		qdel(src) //TODO: silent deleting looks weird

/obj/machinery/atmospherics/unary/vent/burstpipe/ex_act(var/severity)
	return // We're already damaged. :^)

// Tell nodes to fix their networks.
/obj/machinery/atmospherics/unary/vent/burstpipe/proc/do_connect()
	//var/flip = turn(dir, 180)
	initialize_directions = dir
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize()
	build_network()
	if (node)
		node.initialize()
		node.build_network()

/obj/machinery/atmospherics/unary/vent/burstpipe/attackby(var/obj/item/weapon/W, var/mob/user)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You begin to remove \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] removes \the [src].", \
			"\blue You have removed \the [src].", \
			"You hear a ratchet.")
		//new /obj/item/pipe(T, make_from=src)
		del(src)

/obj/machinery/atmospherics/unary/vent/burstpipe/heat_exchanging
	icon_state = "burst_he"
	name = "burst heat exchange pipe"
	desc = "Looks like an overturned bowl of spaghetti ravaged by wolves."
	//level = 1
	volume = 1000 // large volume
	dir = SOUTH
	initialize_directions = SOUTH

/obj/machinery/atmospherics/unary/vent/burstpipe/heat_exchanging/getNodeType(var/node_id)
	return PIPE_TYPE_HE