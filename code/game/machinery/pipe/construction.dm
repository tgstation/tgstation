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
	inhand_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	///Piping layer that we are going to be on
	var/piping_layer = PIPING_LAYER_DEFAULT
	///Type of pipe-object made, selected from the RPD
	var/RPD_type
	///Whether it can be painted
	var/paintable = FALSE
	///Color of the pipe is going to be made from this pipe-object
	var/pipe_color
	///Initial direction of the created pipe (either made from the RPD or after unwrenching the pipe)
	var/p_init_dir = SOUTH

/obj/item/pipe/directional
	RPD_type = PIPE_UNARY
/obj/item/pipe/binary
	RPD_type = PIPE_STRAIGHT
/obj/item/pipe/binary/bendable
	RPD_type = PIPE_BENDABLE
/obj/item/pipe/trinary
	RPD_type = PIPE_TRINARY
/obj/item/pipe/trinary/flippable
	RPD_type = PIPE_TRIN_M
	var/flipped = FALSE
/obj/item/pipe/quaternary
	RPD_type = PIPE_ONEDIR

/obj/item/pipe/ComponentInitialize()
	//Flipping handled manually due to custom handling for trinary pipes
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/item/pipe/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from, device_color, device_init_dir = SOUTH)
	if(make_from)
		make_from_existing(make_from)
	else
		p_init_dir = device_init_dir
		pipe_type = _pipe_type
		pipe_color = device_color
		setDir(_dir)

	update()
	pixel_x += rand(-5, 5)
	pixel_y += rand(-5, 5)
	return ..()

/obj/item/pipe/proc/make_from_existing(obj/machinery/atmospherics/make_from)
	p_init_dir = make_from.initialize_directions
	setDir(make_from.dir)
	pipename = make_from.name
	add_atom_colour(make_from.color, FIXED_COLOUR_PRIORITY)
	pipe_type = make_from.type
	paintable = make_from.paintable
	pipe_color = make_from.pipe_color

/obj/item/pipe/trinary/flippable/make_from_existing(obj/machinery/atmospherics/components/trinary/make_from)
	..()
	if(make_from.flipped)
		do_a_flip()

/obj/item/pipe/dropped()
	if(loc)
		setPipingLayer(piping_layer)
	return ..()

/obj/item/pipe/proc/setPipingLayer(new_layer = PIPING_LAYER_DEFAULT)
	var/obj/machinery/atmospherics/fakeA = pipe_type

	if(initial(fakeA.pipe_flags) & PIPING_ALL_LAYER)
		new_layer = PIPING_LAYER_DEFAULT
	piping_layer = new_layer

	PIPING_LAYER_SHIFT(src, piping_layer)
	layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

/obj/item/pipe/proc/update()
	var/obj/machinery/atmospherics/fakeA = pipe_type
	name = "[initial(fakeA.name)] fitting"
	icon_state = initial(fakeA.pipe_state)
	if(ispath(pipe_type,/obj/machinery/atmospherics/pipe/heat_exchanging))
		resistance_flags |= FIRE_PROOF | LAVA_PROOF

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)

	if ( usr.incapacitated() )
		return

	do_a_flip()

/obj/item/pipe/proc/do_a_flip()
	setDir(turn(dir, -180))

/obj/item/pipe/trinary/flippable/do_a_flip()
	setDir(turn(dir, flipped ? 45 : -45))
	flipped = !flipped

/obj/item/pipe/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

// Convert dir of fitting into dir of built component
/obj/item/pipe/proc/fixed_dir()
	return dir

/obj/item/pipe/binary/fixed_dir()
	. = dir
	if(dir == SOUTH)
		. = NORTH
	else if(dir == WEST)
		. = EAST

/obj/item/pipe/trinary/flippable/fixed_dir()
	. = dir
	if(ISDIAGONALDIR(dir))
		. = turn(dir, 45)

/obj/item/pipe/attack_self(mob/user)
	setDir(turn(dir,-90))

///Check if the pipe on the turf and our to be placed binary pipe are perpendicular to each other
/obj/item/pipe/proc/check_ninety_degree_dir(obj/machinery/atmospherics/machine)
	if(ISDIAGONALDIR(machine.dir))
		return FALSE
	if(EWCOMPONENT(machine.dir) && EWCOMPONENT(dir))
		return FALSE
	if(NSCOMPONENT(machine.dir) && NSCOMPONENT(dir))
		return FALSE
	return TRUE

/obj/item/pipe/wrench_act(mob/living/user, obj/item/wrench/wrench)
	. = ..()
	if(!isturf(loc))
		return TRUE

	add_fingerprint(user)

	var/obj/machinery/atmospherics/fakeA = pipe_type
	var/flags = initial(fakeA.pipe_flags)
	var/pipe_count = 0
	for(var/obj/machinery/atmospherics/machine in loc)
		if(machine.piping_layer != piping_layer)
			continue
		pipe_count += 1
	for(var/obj/machinery/atmospherics/machine in loc)
		if((machine.pipe_flags & flags & PIPING_ONE_PER_TURF)) //Only one dense/requires density object per tile, eg connectors/cryo/heater/coolers.
			to_chat(user, "<span class='warning'>Something is hogging the tile!</span>")
			return TRUE

		if(pipe_count == 1 && istype(machine, /obj/machinery/atmospherics/pipe/smart) && ispath(pipe_type, /obj/machinery/atmospherics/pipe/smart) && lowertext(machine.pipe_color) != lowertext(pipe_color) && machine.connection_num < 3)
			var/direction = machine.dir
			if((direction & EAST|WEST || direction & SOUTH|NORTH) && !ISDIAGONALDIR(direction))
				pipe_type = /obj/machinery/atmospherics/pipe/bridge_pipe
				if(EWCOMPONENT(direction))
					dir = NORTH
				if(NSCOMPONENT(direction))
					dir = EAST
				continue

		if(flags & PIPING_BRIDGE && !(machine.pipe_flags & PIPING_BRIDGE) && check_ninety_degree_dir(machine)) //continue if we are placing a bridge pipe over a normal pipe only (prevent duplicates)
			continue

		if((machine.piping_layer != piping_layer) && !((machine.pipe_flags | flags) & PIPING_ALL_LAYER)) //don't continue if either pipe goes across all layers
			continue

		if(machine.GetInitDirections() & SSair.get_init_dirs(pipe_type, fixed_dir(), p_init_dir)) // matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			return TRUE
	// no conflicts found

	var/obj/machinery/atmospherics/built_machine = new pipe_type(loc, , , p_init_dir)
	build_pipe(built_machine)
	built_machine.on_construction(pipe_color, piping_layer)
	transfer_fingerprints_to(built_machine)

	wrench.play_tool_sound(src)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='hear'>You hear ratcheting.</span>")

	qdel(src)

/obj/item/pipe/proc/build_pipe(obj/machinery/atmospherics/A)
	A.setDir(fixed_dir())
	A.SetInitDirections(p_init_dir)

	if(pipename)
		A.name = pipename
	if(A.on)
		// Certain pre-mapped subtypes are on by default, we want to preserve
		// every other aspect of these subtypes (name, pre-set filters, etc.)
		// but they shouldn't turn on automatically when wrenched.
		A.on = FALSE

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
	desc = "A meter that can be wrenched on pipes, or attached to the floor with screws."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	inhand_icon_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/wrench_act(mob/living/user, obj/item/wrench/W)
	. = ..()
	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in loc)
		if(P.piping_layer == piping_layer)
			pipe = P
			break
	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe!</span>")
		return TRUE
	new /obj/machinery/meter(loc, piping_layer)
	W.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/screwdriver_act(mob/living/user, obj/item/S)
	. = ..()
	if(.)
		return TRUE

	if(!isturf(loc))
		to_chat(user, "<span class='warning'>You need to fasten it to the floor!</span>")
		return TRUE

	new /obj/machinery/meter/turf(loc, piping_layer)
	S.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the [loc.name].</span>")
	qdel(src)

/obj/item/pipe_meter/dropped()
	. = ..()
	if(loc)
		setAttachLayer(piping_layer)

/obj/item/pipe_meter/proc/setAttachLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, piping_layer)
