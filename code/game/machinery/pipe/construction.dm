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
	throwforce = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	level = 2
	var/flipped = 0
	var/is_bent = 0

	var/static/list/pipe_types = list(
		PIPE_SIMPLE, \
		PIPE_MANIFOLD, \
		PIPE_4WAYMANIFOLD, \
		PIPE_HE, \
		PIPE_HE_MANIFOLD, \
		PIPE_HE_4WAYMANIFOLD, \
		PIPE_JUNCTION, \
		\
		PIPE_CONNECTOR, \
		PIPE_UVENT, \
		PIPE_SCRUBBER, \
		PIPE_INJECTOR, \
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

/obj/item/pipe/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/item/pipe/New(loc, pipe_type, dir, obj/machinery/atmospherics/make_from)
	..()
	if(make_from)
		src.setDir(make_from.dir)
		src.pipename = make_from.name
		add_atom_colour(make_from.color, FIXED_COLOUR_PRIORITY)

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
			src.setDir(turn(src.dir, -45))
	else
		src.pipe_type = pipe_type
		src.setDir(dir)

	if(src.dir in GLOB.diagonals)
		is_bent = 1

	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type
GLOBAL_LIST_INIT(pipeID2State, list(
	"[PIPE_SIMPLE]"			 = "simple", \
	"[PIPE_MANIFOLD]"		 = "manifold", \
	"[PIPE_4WAYMANIFOLD]"	 = "manifold4w", \
	"[PIPE_HE]"				 = "he", \
	"[PIPE_HE_MANIFOLD]"	 = "he_manifold", \
	"[PIPE_HE_4WAYMANIFOLD]" = "he_manifold4w", \
	"[PIPE_JUNCTION]"		 = "junction", \
	\
	"[PIPE_CONNECTOR]"		 = "connector", \
	"[PIPE_UVENT]"			 = "uvent", \
	"[PIPE_SCRUBBER]"		 = "scrubber", \
	"[PIPE_INJECTOR]"		 = "injector", \
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
))

/obj/item/pipe/proc/update()
	var/list/nlist = list(\
		"[PIPE_SIMPLE]" 		= "pipe", \
		"[PIPE_SIMPLE]_b" 		= "bent pipe", \
		"[PIPE_MANIFOLD]" 		= "manifold", \
		"[PIPE_4WAYMANIFOLD]" 	= "4-way manifold", \
		"[PIPE_HE]" 			= "h/e pipe", \
		"[PIPE_HE]_b" 			= "bent h/e pipe", \
		"[PIPE_HE_MANIFOLD]"	= "h/e manifold", \
		"[PIPE_HE_4WAYMANIFOLD]"= "h/e 4-way manifold", \
		"[PIPE_JUNCTION]" 		= "junction", \
		\
		"[PIPE_CONNECTOR]" 		= "connector", \
		"[PIPE_UVENT]" 			= "vent", \
		"[PIPE_SCRUBBER]" 		= "scrubber", \
		"[PIPE_INJECTOR]"		= "injector", \
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
	icon_state = GLOB.pipeID2State["[pipe_type]"]

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	src.setDir(turn(src.dir, -90))

	fixdir()

	return

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	if (pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER))
		src.setDir(turn(src.dir, flipped )? 45 : -45)
		flipped = !flipped
		return

	src.setDir(turn(src.dir, -180))

	fixdir()

	return

/obj/item/pipe/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		rotate()

/obj/item/pipe/Move()
	var/old_dir = dir
	..()
	setDir(old_dir )//pipes changing direction when moved is just annoying and buggy

/obj/item/pipe/proc/unflip(direction)
	if(direction in GLOB.diagonals)
		return turn(direction, 45)

	return direction

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	if((pipe_type in list (PIPE_SIMPLE, PIPE_HE, PIPE_MVALVE, PIPE_DVALVE)) && !is_bent)
		if(dir==SOUTH)
			setDir(NORTH)
		else if(dir==WEST)
			setDir(EAST)

/obj/item/pipe/attack_self(mob/user)
	return rotate()

/obj/item/pipe/attackby(obj/item/W, mob/user, params)
	if (!istype(W, /obj/item/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1

	fixdir()
	if(pipe_type in list(PIPE_GAS_MIXER, PIPE_GAS_FILTER))
		setDir(unflip(dir))

	var/obj/machinery/atmospherics/A = new pipe_type(src.loc)
	A.setDir(src.dir)
	A.SetInitDirections()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M == A) //we don't want to check to see if it interferes with itself
			continue
		if(M.GetInitDirections() & A.GetInitDirections())	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			qdel(A)
			return 1
	// no conflicts found

	if(pipename)
		A.name = pipename

	var/obj/machinery/atmospherics/components/trinary/T = A
	if(istype(T))
		T.flipped = flipped
	A.on_construction(pipe_type, color)

	playsound(src.loc, W.usesound, 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratchet.</span>")

	qdel(src)

/obj/item/pipe/suicide_act(mob/user)
	if(pipe_type in list(PIPE_PUMP, PIPE_PASSIVE_GATE, PIPE_VOLUME_PUMP))
		user.visible_message("<span class='suicide'>[user] shoves the [src] in [user.p_their()] mouth and turns it on!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			for(var/i=1 to 20)
				C.vomit(0, TRUE, FALSE, 4, FALSE)
				if(prob(20))
					C.spew_organ()
				sleep(5)
			C.blood_volume = 0
		return(OXYLOSS|BRUTELOSS)
	else
		return ..()

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/pipe_meter/attackby(obj/item/W, mob/user, params)
	..()

	if (!istype(W, /obj/item/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe!</span>")
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, W.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You fasten the meter to the pipe.</span>")
	qdel(src)
