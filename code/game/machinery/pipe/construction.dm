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
	var/pipe_type
	var/pipename
	force = 7
	throwforce = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	level = 2
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/RPD_type //TEMP: kill this once RPDs get a rewrite pls

/obj/item/pipe/directional
	RPD_type = PIPE_UNARY
/obj/item/pipe/binary
	RPD_type = PIPE_BINARY
/obj/item/pipe/binary/bendable
	RPD_type = PIPE_BENDABLE
/obj/item/pipe/trinary
	RPD_type = PIPE_TRINARY
/obj/item/pipe/trinary/flippable
	RPD_type = PIPE_TRIN_M
	var/flipped = FALSE
/obj/item/pipe/quaternary
	RPD_type = PIPE_QUAD

/obj/item/pipe/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/item/pipe/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from)
	if(make_from)
		make_from_existing(make_from)
	else
		pipe_type = _pipe_type
		setDir(_dir)

	update()
	pixel_x += rand(-5, 5)
	pixel_y += rand(-5, 5)
	return ..()

/obj/item/pipe/proc/make_from_existing(obj/machinery/atmospherics/make_from)
	setDir(make_from.dir)
	pipename = make_from.name
	add_atom_colour(make_from.color, FIXED_COLOUR_PRIORITY)
	pipe_type = make_from.type

/obj/item/pipe/trinary/flippable/make_from_existing(obj/machinery/atmospherics/components/trinary/make_from)
	..()
	if(make_from.flipped)
		do_a_flip()

/obj/item/pipe/dropped()
	if(loc)
		setPipingLayer(piping_layer)
	return ..()

/obj/item/pipe/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	var/obj/machinery/atmospherics/fakeA = get_pipe_cache(pipe_type)

	if(fakeA.pipe_flags & PIPING_ALL_LAYER)
		new_layer = PIPING_LAYER_DEFAULT
	piping_layer = new_layer

	pixel_x += (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
	pixel_y += (piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y
	layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

/obj/item/pipe/proc/update()
	var/obj/machinery/atmospherics/A = get_pipe_cache(pipe_type)
	name = "[A.name] fitting"
	icon_state = A.pipe_state

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	setDir(turn(dir, -90))
	fixdir()

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() || !usr.canmove )
		return

	do_a_flip()

/obj/item/pipe/proc/do_a_flip()
	setDir(turn(dir, -180))
	fixdir()

/obj/item/pipe/trinary/flippable/do_a_flip()
	setDir(turn(dir, flipped ? 45 : -45))
	flipped = !flipped

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
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

//Helper to clean up dir
/obj/item/pipe/proc/fixdir()
	return

/obj/item/pipe/binary/fixdir()
	if(dir == SOUTH)
		setDir(NORTH)
	else if(dir == WEST)
		setDir(EAST)

/obj/item/pipe/trinary/flippable/fixdir()
	if(dir in GLOB.diagonals)
		setDir(turn(dir, 45))

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

	var/obj/machinery/atmospherics/fakeA = get_pipe_cache(pipe_type, dir)

	for(var/obj/machinery/atmospherics/M in loc)
		if((M.pipe_flags & fakeA.pipe_flags & PIPING_ONE_PER_TURF))	//Only one dense/requires density object per tile, eg connectors/cryo/heater/coolers.
			to_chat(user, "<span class='warning'>Something is hogging the tile!</span>")
			return TRUE
		if((M.piping_layer != piping_layer) && !((M.pipe_flags | fakeA.pipe_flags) & PIPING_ALL_LAYER)) //don't continue if either pipe goes across all layers
			continue
		if(M.GetInitDirections() & fakeA.GetInitDirections())	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			return TRUE
	// no conflicts found

	var/obj/machinery/atmospherics/A = new pipe_type(loc)
	build_pipe(A)
	A.on_construction(color, piping_layer)

	playsound(src, W.usesound, 50, 1)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")

	qdel(src)

/obj/item/pipe/proc/build_pipe(obj/machinery/atmospherics/A)
	A.setDir(dir)
	A.SetInitDirections()

	if(pipename)
		A.name = pipename

/obj/item/pipe/trinary/flippable/build_pipe(obj/machinery/atmospherics/components/trinary/T)
	..()
	T.flipped = flipped

/obj/item/pipe/directional/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] shoves [src] in [user.p_their()] mouth and turns it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		for(var/i=1 to 20)
			C.vomit(0, TRUE, FALSE, 4, FALSE)
			if(prob(20))
				C.spew_organ()
			sleep(5)
		C.blood_volume = 0
	return(OXYLOSS|BRUTELOSS)

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
