/*CONTENTS
Buildable pipes
Buildable meters
*/

//construction defines are in __defines/pipe_construction.dm
//update those defines ANY TIME an atmos path is changed...
//...otherwise construction will stop working

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipename
	force = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = 3
	level = 2
	var/flipped = 0
	var/is_bent = 0

	var/global/list/pipe_types = list(
		PIPE_SIMPLE, \
		PIPE_MANIFOLD, \
		PIPE_4WAYMANIFOLD, \
		PIPE_HE, \
		PIPE_JUNCTION, \
		\
		PIPE_CONNECTOR, \
		PIPE_UVENT, \
		PIPE_SCRUBBER, \
		PIPE_HEAT_EXCHANGE, \
		\
		PIPE_PUMP, \
		PIPE_PASSIVE_GATE, \
		PIPE_VOLUME_PUMP, \
		PIPE_MVALVE, \
		PIPE_DVALVE, \
		\
		PIPE_GAS_FILTER, \
		PIPE_GAS_MIXER, \
	)

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if(make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		src.color = make_from.color

		if(make_from.type in pipe_types)
			src.pipe_type = make_from.type
		else //make pipe_type a value we can work with
			for(var/P in pipe_types)
				if(istype(make_from, P))
					src.pipe_type = P
					break

		var/obj/machinery/atmospherics/components/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			src.flipped = 1
			src.dir = turn(src.dir, -45)
	else
		src.pipe_type = pipe_type
		src.dir = dir

	if(src.dir in diagonals)
		is_bent = 1

	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type
var/global/list/pipeID2State = list(
	"[PIPE_SIMPLE]"			 = "simple", \
	"[PIPE_MANIFOLD]"		 = "manifold", \
	"[PIPE_4WAYMANIFOLD]"	 = "manifold4w", \
	"[PIPE_HE]"				 = "he", \
	"[PIPE_JUNCTION]"		 = "junction", \
	\
	"[PIPE_CONNECTOR]"		 = "connector", \
	"[PIPE_UVENT]"			 = "uvent", \
	"[PIPE_SCRUBBER]"		 = "scrubber", \
	"[PIPE_HEAT_EXCHANGE]"	 = "heunary", \
	\
	"[PIPE_PUMP]"			 = "pump", \
	"[PIPE_PASSIVE_GATE]"	 = "passivegate", \
	"[PIPE_VOLUME_PUMP]"	 = "volumepump", \
	"[PIPE_MVALVE]"			 = "mvalve", \
	"[PIPE_DVALVE]"			 = "dvalve", \
	\
	"[PIPE_GAS_FILTER]"		 = "filter", \
	"[PIPE_GAS_MIXER]"		 = "mixer", \
)

/obj/item/pipe/proc/update()
	var/list/nlist = list(\
		"[PIPE_SIMPLE]" 		= "pipe", \
		"[PIPE_SIMPLE]_b" 		= "bent pipe", \
		"[PIPE_MANIFOLD]" 		= "manifold", \
		"[PIPE_4WAYMANIFOLD]" 	= "4-way manifold", \
		"[PIPE_HE]" 			= "h/e pipe", \
		"[PIPE_HE]_b" 			= "bent h/e pipe", \
		"[PIPE_JUNCTION]" 		= "junction", \
		\
		"[PIPE_CONNECTOR]" 		= "connector", \
		"[PIPE_UVENT]" 			= "vent", \
		"[PIPE_SCRUBBER]" 		= "scrubber", \
		"[PIPE_HEAT_EXCHANGE]" 	= "heat exchanger", \
		\
		"[PIPE_PUMP]" 			= "pump", \
		"[PIPE_PASSIVE_GATE]" 	= "passive gate", \
		"[PIPE_VOLUME_PUMP]" 	= "volume pump", \
		"[PIPE_MVALVE]" 		= "manual valve", \
		"[PIPE_DVALVE]" 		= "digital valve", \
		\
		"[PIPE_GAS_FILTER]" 	= "gas filter", \
		"[PIPE_GAS_MIXER]" 		= "gas mixer", \
		)
	//fix_pipe_type()
	name = nlist["[pipe_type][is_bent ? "_b" : ""]"] + " fitting"
	icon_state = pipeID2State["[pipe_type]"]

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	src.dir = turn(src.dir, -90)

	fixdir()

	return

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	if (pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER))
		src.dir = turn(src.dir, flipped ? 45 : -45)
		flipped = !flipped
		return

	src.dir = turn(src.dir, -180)

	fixdir()

	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE, PIPE_HE)) && is_bent \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if ((pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER)) && flipped)
		src.dir = turn(src.dir, 45+90)
	fixdir()

/obj/item/pipe/proc/unflip(direction)
	if(direction in diagonals)
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if((pipe_type in list (PIPE_SIMPLE, PIPE_HE, PIPE_MVALVE, PIPE_DVALVE)) && !is_bent)
		if(dir==SOUTH)
			dir = NORTH
		else if(dir==WEST)
			dir = EAST

/obj/item/pipe/attack_self(mob/user)
	return rotate()

/obj/item/pipe/attackby(obj/item/weapon/W, mob/user, params)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1

	fixdir()
	if(pipe_type in list(PIPE_GAS_MIXER, PIPE_GAS_FILTER))
		dir = unflip(dir)

	var/obj/machinery/atmospherics/A = new pipe_type(src.loc)
	A.dir = src.dir
	A.SetInitDirections()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M == A) //we don't want to check to see if it interferes with itself
			continue
		if(M.GetInitDirections() & A.GetInitDirections())	// matches at least one direction on either type of pipe
			user << "<span class='warning'>There is already a pipe at that location!</span>"
			qdel(A)
			return 1
	// no conflicts found

	if(pipename)
		A.name = pipename

	var/obj/machinery/atmospherics/components/trinary/T = A
	if(istype(T))
		T.flipped = flipped
	A.construction(pipe_type, color)

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratchet.</span>")

	qdel(src)

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = 4

/obj/item/pipe_meter/attackby(obj/item/weapon/W, mob/user, params)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		user << "<span class='warning'>You need to fasten it to a pipe!</span>"
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "<span class='notice'>You fasten the meter to the pipe.</span>"
	qdel(src)