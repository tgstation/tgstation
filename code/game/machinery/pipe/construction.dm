/*CONTENTS
Buildable pipes
Buildable meters
*/

//construction defines are in __defines/pipe_construction.dm
//update those defines ANY TIME an atmos path is changed...
//...otherwise construction will stop working

/obj/item/pipe
	name = "pipe"
	desc = "A pipe."
	var/pipe_type = 0
	var/pipename
	force = 7
	throwforce = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	level = 2
	var/flipped = FALSE
	var/is_bent = FALSE
	var/piping_layer = PIPING_LAYER_DEFAULT

	var/static/list/pipe_types = list(
		PIPE_SIMPLE, \
		PIPE_LAYER_MANIFOLD, \
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

/obj/item/pipe/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from)
	if(make_from)
		setDir(make_from.dir)
		pipename = make_from.name
		add_atom_colour(make_from.color, FIXED_COLOUR_PRIORITY)

		if(make_from.type in pipe_types)
			pipe_type = make_from.type
			setPipingLayer(make_from.piping_layer)
		else //make pipe_type a value we can work with
			for(var/P in pipe_types)
				if(istype(make_from, P))
					pipe_type = P
					break

		var/obj/machinery/atmospherics/components/trinary/triP = make_from
		if(istype(triP) && triP.flipped)
			flipped = TRUE
			setDir(turn(dir, -45))
	else
		pipe_type = _pipe_type
		setDir(_dir)

	if(_dir in GLOB.diagonals)
		is_bent = TRUE

	update()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	return ..()

/obj/item/pipe/dropped()
	if(loc)
		setPipingLayer(piping_layer)
	return ..()

/obj/item/pipe/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	var/obj/machinery/atmospherics/fakeA = get_pipe_cache(pipe_type)
	var/nolayer = (fakeA.pipe_flags & PIPING_ALL_LAYER)
	if(nolayer)
		new_layer = PIPING_LAYER_DEFAULT
	piping_layer = new_layer
	if(pipe_type != PIPE_LAYER_MANIFOLD)
		pixel_x = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
		pixel_y = (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
		layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

//update the name and icon of the pipe item depending on the type
GLOBAL_LIST_INIT(pipeID2State, list(
	"[PIPE_SIMPLE]"			 = "simple", \
	"[PIPE_MANIFOLD]"		 = "manifold", \
	"[PIPE_LAYER_MANIFOLD]"	 = "layer_manifold", \
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
		"[PIPE_LAYER_MANIFOLD]" = "layer manifold", \
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

	setDir(turn(dir, -90))

	fixdir()

	return

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	if (pipe_type in list(PIPE_GAS_FILTER, PIPE_GAS_MIXER))
		setDir(turn(dir, flipped )? 45 : -45)
		flipped = !flipped
		return

	setDir(turn(dir, -180))

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
	if((pipe_type in list (PIPE_SIMPLE, PIPE_HE, PIPE_MVALVE, PIPE_DVALVE, PIPE_LAYER_MANIFOLD)) && !is_bent)
		if(dir==SOUTH)
			setDir(NORTH)
		else if(dir==WEST)
			setDir(EAST)

/obj/item/pipe/attack_self(mob/user)
	return rotate()

/obj/item/pipe/proc/get_pipe_cache(type, direction)
	var/static/list/obj/machinery/atmospherics/check_cache
	if(!islist(check_cache))
		check_cache = list()
	if(!check_cache[type])
		check_cache[type] = list()
	if(!check_cache[type]["[direction]"])
		check_cache[type]["[direction]"] = new type(null, null, direction)

	return check_cache[type]["[direction]"]

/obj/item/pipe/attackby(obj/item/W, mob/user, params)
	if (!istype(W, /obj/item/wrench))
		return ..()
	if (!isturf(loc))
		return TRUE
	add_fingerprint(user)

	fixdir()
	if(pipe_type in list(PIPE_GAS_MIXER, PIPE_GAS_FILTER))
		setDir(unflip(dir))

	var/obj/machinery/atmospherics/fakeA = get_pipe_cache(pipe_type, dir)

	for(var/obj/machinery/atmospherics/M in loc)
		if((M.pipe_flags & PIPING_ONE_PER_TURF) && (fakeA.pipe_flags & PIPING_ONE_PER_TURF))	//Only one dense/requires density object per tile, eg connectors/cryo/heater/coolers.
			to_chat(user, "<span class='warning'>Something is hogging the tile!</span>")
			return TRUE
		if((M.piping_layer != piping_layer) && !((M.pipe_flags & PIPING_ALL_LAYER) || (pipe_type == PIPE_LAYER_MANIFOLD)))
			continue
		if(M.GetInitDirections() & fakeA.GetInitDirections())	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			return TRUE
	// no conflicts found

	var/obj/machinery/atmospherics/A = new pipe_type(loc)
	A.setDir(dir)
	A.SetInitDirections()

	if(pipename)
		A.name = pipename

	var/obj/machinery/atmospherics/components/trinary/T = A
	if(istype(T))
		T.flipped = flipped
	A.on_construction(pipe_type, color, piping_layer)

	playsound(src, W.usesound, 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")

	qdel(src)

/obj/item/pipe/suicide_act(mob/user)
	if(pipe_type in list(PIPE_PUMP, PIPE_PASSIVE_GATE, PIPE_VOLUME_PUMP))
		user.visible_message("<span class='suicide'>[user] shoves [src] in [user.p_their()] mouth and turns it on!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
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
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/attackby(obj/item/I, mob/user, params)
	..()

	if (!istype(I, /obj/item/wrench))
		return ..()
	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in loc)
		if(P.piping_layer == piping_layer)
			pipe = P
			break
	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe!</span>")
		return TRUE
	new /obj/machinery/meter(loc, piping_layer)
	playsound(src, I.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You fasten the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/dropped()
	. = ..()
	if(loc)
		setAttachLayer(piping_layer)

/obj/item/pipe_meter/proc/setAttachLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	pixel_x = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	pixel_y = (new_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

